import csv
import itertools
import json
import logging
import os
import pathlib
import random
import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from queue import Queue
from typing import Any, Dict, List, Optional

from . import connectors
from .exporters import CSVExporter, VisualExporter

ITERATIONS_PER_QUERY = 5

@dataclass
class QueryResult:
    query_number: int
    execution_time: float
    concurrent_run: int
    success: bool
    error: Optional[str] = None
    vendor: Optional[str] = None
    query_name: Optional[str] = None

class ConnectionPool:
    def __init__(self, connector, credentials: Dict, pool_size: int = 5):
        self.connector = connector
        self.credentials = credentials
        self.pool_size = pool_size
        self.connections = Queue(maxsize=pool_size)
        self._lock = threading.Lock()
        self._fill_pool()

    def _fill_pool(self):
        for _ in range(self.pool_size):
            # Create a new connector instance for each connection
            connector = self.connector.__class__(config=self.credentials)
            connector.connect()
            self.connections.put(connector)

    def get_connection(self):
        return self.connections.get()

    def return_connection(self, connector):
        self.connections.put(connector)

    def close_all(self):
        while not self.connections.empty():
            connector = self.connections.get()
            connector.close()

class BenchmarkRunner:
    def __init__(
        self,
        benchmark_name: str,
        creds_file: str,
        vendors: List[str] = None,
        pool_size: int = ITERATIONS_PER_QUERY,
        concurrency: int = 1,
        output_dir: str = 'benchmark_results',
        execute_setup: bool = False,
        benchmark_path: str = ""
    ):
        self.benchmark_name = benchmark_name
        self.vendors = vendors
        self.concurrency = concurrency
        #  pool_size cannot be smaller than the expected concurrency level
        self.pool_size =  pool_size if concurrency <= pool_size else concurrency
        self.output_dir = output_dir
        self.execute_setup = execute_setup
        self.logger = logging.getLogger(__name__)
        self.benchmark_path = benchmark_path
        self.connection_pools = {}
        
        # Load credentials
        with open(creds_file, 'r') as f:
            self.credentials = json.load(f)
            
        # Initialize connectors
        self.connectors = {}
        for vendor in vendors:
            if vendor not in self.credentials:
                raise ValueError(f"No credentials found for vendor: {vendor}")

            connector_class = connectors.get_connector_class(vendor)
            self.connectors[vendor] = connector_class(config=self.credentials[vendor])

    def _load_queries(self, query_file):
        if isinstance(query_file, (str, bytes, os.PathLike)):
            with open(query_file, 'r') as f:
                # Read the entire file and split by newlines first
                lines = f.readlines()
                queries = []
                current_query = []

                for line in lines:
                    line = line.strip()
                    # Skip empty lines
                    if not line:
                        continue
                    # Remove inline comments
                    line = line.split('--')[0].strip()  # Remove everything after '--'
                    # Skip lines that are now empty after removing comments
                    if not line:
                        continue
                    # If the line ends with a semicolon, it's a complete query
                    if line.endswith(';'):
                        current_query.append(line[:-1])  # Remove the semicolon
                        queries.append(' '.join(current_query).strip())
                        current_query = []  # Reset for the next query
                    else:
                        current_query.append(line)

                # Handle any remaining query that doesn't end with a semicolon
                if current_query:
                    queries.append(' '.join(current_query).strip())

                return queries
        elif isinstance(query_file, list):
            return query_file
        else:
            raise TypeError("query_file must be a file path or list of queries")

    def _run_query(self, vendor: str, query_name: str, query: str, concurrent_run: int) -> Dict[str, Any]:
        """Execute a single query and return its results."""
        start_time = time.time()
        try:
            # Acquire a connection from the pool
            connection = self.connection_pools[vendor].get_connection()
            results = connection.execute_query(query)
            duration = time.time() - start_time
            
            return {
                'vendor': vendor,
                'query_name': query_name,
                'duration': duration,
                'rows': len(results) if results else 0,
                'status': 'success',
                'timestamp': datetime.now().isoformat(),
                'concurrent_run': concurrent_run
            }
        except Exception as e:
            self.logger.error(f"Error running query {query_name} for {vendor}: {str(e)}")
            return {
                'vendor': vendor,
                'query_name': query_name,
                'duration': time.time() - start_time,
                'rows': 0,
                'status': 'error',
                'error': str(e),
                'timestamp': datetime.now().isoformat(),
                'concurrent_run': concurrent_run
            }
        finally:
            # Return the connection to the pool
            self.connection_pools[vendor].return_connection(connection)

    def _run_concurrent_query(self, vendor: str, query: str, query_number: int) -> List[QueryResult]:
        """Run a query concurrently and return the results."""
        results = []
        with ThreadPoolExecutor(max_workers=self.concurrency) as executor:
            future_to_query = {executor.submit(self._run_query, vendor, query_number, query, i+1): query for i in range(self.concurrency)}
            
            for future in as_completed(future_to_query):
                try:
                    result = future.result()
                    results.append(QueryResult(
                        query_number=query_number,
                        execution_time=result['duration'],
                        success=result['status'] == 'success',
                        error=result.get('error'),
                        vendor=result['vendor'],
                        query_name=result['query_name'],
                        concurrent_run=result['concurrent_run']
                    ))
                except Exception as e:
                    self.logger.error(f"Error in concurrent execution: {str(e)}")
        
        return results
    
    def _get_sql_file(self, vendor, file_type):
        # Construct the general and vendor-specific file paths
        general_file= Path(self.benchmark_path) / f"{file_type}.sql"
        # general_file = os.path.join(self.benchmark_path, f"{file_type}.sql")
        vendor_file = Path(self.benchmark_path) / f"{vendor}"/ f"{file_type}.sql"

        # Check if vendor-specific file exists, return it if it does, otherwise return the general file
        if os.path.exists(vendor_file):
            return vendor_file
        return general_file


    def run_benchmark(self) -> Dict:
        results = {}
        num_iterations = ITERATIONS_PER_QUERY if self.concurrency == 1 else 1 # Run each query multiple times to get a distribution

        def run_vendor_benchmark(vendor):
            if vendor not in self.connectors:
                self.logger.warning(f"Skipping {vendor} - connector not implemented")
                return vendor, []

            self.logger.info(f"Running benchmark for {vendor.upper()}...")

            # Execute setup script if execute_setup is True
            if self.execute_setup:
                if not self._execute_setup_script(vendor):  # Only run benchmark if setup succeeded
                    self.logger.warning("Skipping benchmark due to setup failure.")
                    return vendor, []

            vendor_results = []

            try:
                self.connection_pools[vendor] = ConnectionPool(
                    self.connectors[vendor],
                    self.credentials[vendor],
                    self.pool_size
                )

                # Load the appropriate benchmark SQL file for the vendor
                benchmark_file = self._get_sql_file(vendor, 'benchmark')
                benchmark_queries = self._load_queries(benchmark_file)
                if not benchmark_queries:
                    raise ValueError(f"No benchmark queries found for vendor: {vendor}")
                self.logger.info(f"Loaded {len(benchmark_queries)} benchmark queries for: {vendor}")

                for query_number, query in enumerate(benchmark_queries, 1):
                    self.logger.info(f"Running query {query_number} with {self.concurrency} concurrent executions...")
                    # Run each query multiple times
                    for iteration in range(num_iterations):
                        self.logger.info(f"  Iteration {iteration + 1}/{num_iterations}")
                        query_results = self._run_concurrent_query(vendor, query, query_number)
                        vendor_results.extend(query_results)

                # Prepare data for CSV export
                csv_data = [
                    {
                        'vendor': result.vendor,
                        'query_name': result.query_name,
                        'execution_time': result.execution_time,
                        'concurrent_run': result.concurrent_run,
                        'success': result.success,
                        'error': result.error
                    }
                    for result in vendor_results
                ]

            except Exception as e:
                self.logger.error(f"Error running benchmark for {vendor}: {str(e)}")
                csv_data = []
            finally:
                 # Ensure proper cleanup
                self.connection_pools[vendor].close_all()
                self.connectors[vendor].close() 

            return vendor, csv_data

        with ThreadPoolExecutor(max_workers=len(self.vendors)) as executor:
            future_to_vendor = {executor.submit(run_vendor_benchmark, vendor): vendor for vendor in self.vendors}
            for future in as_completed(future_to_vendor):
                vendor, csv_data = future.result()
                if csv_data:
                    results[vendor] = csv_data

        if not results:
            self.logger.warning("No results were generated from the benchmark.")
        else:
            # Ensure the directory exists
            os.makedirs(self.output_dir, exist_ok=True)
            # Use the CSV Exporter to export results
            csv_exporter = CSVExporter()
            csv_exporter.export(results, self.output_dir)

            # Visual export
            visual_exporter = VisualExporter(self.output_dir)
            visual_exporter.export(results, self.output_dir)

        return results

    def _execute_setup_script(self, vendor: str):
        """Execute the setup SQL script for the vendor."""
        try:
            # Load the setup SQL file for the vendor
            setup_file = self._get_sql_file(vendor, 'setup')
            setup_queries = self._load_queries(setup_file)
            for query in setup_queries:
                self.connectors[vendor].execute_query(query)
            self.logger.info(f"Executed setup script: {setup_file}")
        except Exception as e:
            self.logger.error(f"Error executing setup script {setup_file}: {str(e)}")
            return False
        return True


@dataclass
class ConcurrentQueryResult:
    query_name: str
    query_id: int
    has_error: bool
    num_output_rows: int
    start_unix_time: float
    stop_unix_time: float


class ConcurrentBenchmarkRunner:
    def __init__(
        self,
        benchmark_name: str,
        creds_file: str,
        vendor: str,
        concurrency: int,
        benchmark_duration_secs: int,
        output_dir: str,
        benchmark_path: str,
        seed: int,
    ):
        self.benchmark_name = benchmark_name
        self.vendor = vendor
        self.concurrency = concurrency
        self.benchmark_duration_secs = benchmark_duration_secs
        self.output_dir = output_dir
        self.benchmark_path = benchmark_path
        self.logger = logging.getLogger(__name__)
        self.connector_class = connectors.get_connector_class(self.vendor)
        self.seed = seed

        # Load credentials
        with open(creds_file, "r") as f:
            all_credentials = json.load(f)
            if vendor not in all_credentials:
                raise ValueError(f"No credentials found for vendor: {vendor}")
            self.credentials = all_credentials[vendor]

        # Load queries
        queries_file = self._get_sql_file(vendor)
        with open(queries_file, "r") as f:
            self.queries = json.load(f)
        if not self.queries:
            raise ValueError(f"No benchmark queries found for vendor: {vendor}")

        # Get the names of the queries
        self.query_names = list(self.queries.keys())
        self.logger.info(
            f"Loaded {len(self.query_names)} benchmark queries for: {vendor}"
        )

    def _get_sql_file(self, vendor):
        general_file = pathlib.Path(self.benchmark_path) / "queries.json"
        vendor_file = pathlib.Path(self.benchmark_path) / f"{vendor}" / "queries.json"
        return vendor_file if os.path.exists(vendor_file) else general_file

    def _run_worker(self, worker_id: int, seed: int):
        # Seed the random number generator for reproducibility
        rng = random.Random(seed)
        # Each worker thread should execute the queries in a random order
        query_names_random_permutation = rng.sample(
            self.query_names, len(self.query_names)
        )
        # Connect to the database
        connector = self.connector_class(config=self.credentials)
        connector.connect(True)
        results = []

        random_queries = []
        for i, query_name in enumerate(itertools.cycle(query_names_random_permutation)):
            # Choose a random variation of the query
            random_query_variation = rng.choice(self.queries[query_name])
            random_queries.append(random_query_variation)
            if i == 10_000:
                break

        # Wait until all worker threads are ready
        self.start_barrier.wait()

        # The query ID increases by one for each executed query
        query_id = 0

        # Repeatedly iterate over the queries until the main thread sets `self.stop_event`
        while True:
            for random_query_variation in random_queries:
                try:
                    has_error = False
                    start_time = time.time()
                    num_output_rows = len(
                        connector.execute_query(random_query_variation)
                    )
                    stop_time = time.time()
                except Exception as e:
                    has_error = True
                    self.logger.error(
                        f"Error running query {query_name} for {self.vendor}: {str(e)}"
                    )

                if self.stop_event.is_set():
                    # Stop the worker thread. The current query did not finish in time and should not
                    # be included in `self.worker_thread_results`.
                    self.worker_thread_results[worker_id] = results
                    connector.close()
                    return
                else:
                    results.append(
                        ConcurrentQueryResult(
                            query_name=query_name,
                            query_id=query_id,
                            has_error=has_error,
                            num_output_rows=0 if has_error else num_output_rows,
                            start_unix_time=start_time,
                            stop_unix_time=stop_time,
                        )
                    )
                    query_id += 1

    def _write_csv(self):
        # Ensure the directory exists
        os.makedirs(self.output_dir, exist_ok=True)
        csv_file_path = os.path.join(self.output_dir, f"{self.vendor}_concurrency.csv")
        with open(csv_file_path, mode="w", newline="") as csv_file:
            field_names = [
                "worker_id",
                "query_name",
                "query_id",
                "has_error",
                "num_output_rows",
                "start_unix_time",
                "stop_unix_time",
            ]
            writer = csv.DictWriter(csv_file, fieldnames=field_names)
            writer.writeheader()
            for worker_id, worker_results in enumerate(self.worker_thread_results):
                if not worker_results:
                    self.logger.warning(f"No results found for worker {worker_id}")
                for result in worker_results:
                    row = {
                        "worker_id": worker_id,
                        "query_name": result.query_name,
                        "query_id": result.query_id,
                        "has_error": result.has_error,
                        "num_output_rows": result.num_output_rows,
                        "start_unix_time": result.start_unix_time,
                        "stop_unix_time": result.stop_unix_time,
                    }
                    writer.writerow(row)
        self.logger.info(f"Concurrency benchmark results exported to {csv_file_path}")

    def run_benchmark(self):
        self.logger.info(f"Running concurrency benchmark for {self.vendor.upper()}...")
        self.start_barrier = threading.Barrier(self.concurrency)
        self.stop_event = threading.Event()
        self.worker_thread_results = [[] for _ in range(self.concurrency)]

        # Get random seeds for the worker threads (but seed the random seed generator with `self.seed` for reproducibility)
        rng = random.Random(self.seed)
        random_seeds = rng.sample(range(42_000_000), self.concurrency)

        # Start `self.concurrency` worker threads
        threads = []
        for i in range(self.concurrency):
            thread = threading.Thread(
                target=self._run_worker, args=(i, random_seeds[i])
            )
            threads.append(thread)
            thread.start()

        # Let the worker threads work for `self.benchmark_duration_secs` seconds
        time.sleep(self.benchmark_duration_secs)
        self.stop_event.set()

        # Wait for all worker threads to finish
        for thread in threads:
            thread.join()

        self._write_csv()
        self.logger.info(f"Finished concurrency benchmark for {self.vendor.upper()}...")
