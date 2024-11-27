import json
import logging
from pathlib import Path
from typing import List, Dict, Any, Optional
from concurrent.futures import ThreadPoolExecutor, as_completed
import time
from datetime import datetime
import os
import threading
from queue import Queue
from dataclasses import dataclass

from .connectors import (
    SnowflakeConnector,
    FireboltConnector,
    BigQueryConnector,
    RedshiftConnector
)
from .exporters import CSVExporter, VisualExporter


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
            connector = self.connector
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
        pool_size: int = 5,
        concurrency: int = 1,
        output_dir: str = 'benchmark_results',
        execute_setup: bool = False,
        benchmark_path: str = ""
    ):
        self.benchmark_name = benchmark_name
        self.vendors = vendors
        self.pool_size = pool_size
        self.concurrency = concurrency
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
            
            connector_class = self._get_connector_class(vendor)
            self.connectors[vendor] = connector_class(config=self.credentials[vendor])

    def _get_connector_class(self, vendor: str):
        """Get the appropriate connector class for a vendor."""
        connector_map = {
            'snowflake': SnowflakeConnector,
            'firebolt': FireboltConnector,
            'bigquery': BigQueryConnector,
            'redshift': RedshiftConnector
        }
        if vendor not in connector_map:
            raise ValueError(f"Unsupported vendor: {vendor}")
        return connector_map[vendor]

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
            connector = self.connectors[vendor]
            results = connector.execute_query(query)
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
        num_iterations = 1  # Run each query multiple times to get a distribution
        
        for vendor in self.vendors:
            if vendor not in self.connectors:
                print(f"Skipping {vendor} - connector not implemented")
                continue

            print(f"\nRunning benchmark for {vendor.upper()}...")

            # Execute setup script if execute_setup is True
            if self.execute_setup:
                if not self._execute_setup_script(vendor):  # Only run benchmark if setup succeeded
                    print("Skipping benchmark due to setup failure.")
                    return  # 
                
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
                    raise ValueError(f"No benchmark queries found for vendor : {vendor}")
                self.logger.info(f"Loaded {len(benchmark_queries)} benchmark queries for : {vendor}")
                for query_number, query in enumerate(benchmark_queries, 1):
                    print(f"Running query {query_number} with {self.concurrency} concurrent executions...")
                    # Run each query multiple times
                    for iteration in range(num_iterations):
                        print(f"  Iteration {iteration + 1}/{num_iterations}")
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
                
                results[vendor] = csv_data  # Store the formatted data for this vendor        
                self.connection_pools[vendor].close_all()
                
            except Exception as e:
                self.logger.error(f"Error running benchmark for {vendor}: {str(e)}")
            finally:
                self.connectors[vendor].close()  # Ensure proper cleanup

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
