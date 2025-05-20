import argparse
import logging
import os
from pathlib import Path

from .runner import BenchmarkRunner, ConcurrentBenchmarkRunner


def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )

def validate_benchmark(benchmark_name: str) -> str:
    """
    Validate that the benchmark exists and return its full path.
    
    Args:
        benchmark_name: Name of the benchmark
        
    Returns:
        str: Full path to benchmark directory
        
    Raises:
        ValueError: If benchmark directory doesn't exist
    """
    benchmark_path = Path(__file__).parent.parent.parent.parent / 'benchmarks' / benchmark_name
    if not benchmark_path.exists():
        raise ValueError(
            f"Benchmark '{benchmark_name}' not found in benchmarks directory. "
            f"Available benchmarks: {', '.join(os.listdir(Path(__file__).parent.parent.parent / 'benchmarks'))}"
        )
    return str(benchmark_path)

def parse_vendors(vendors_arg: str) -> list:
    """
    Parse vendors argument string into a list.
    
    Args:
        vendors_arg: Comma-separated string of vendor names
        
    Returns:
        list: List of vendor names
    """
    if ',' in vendors_arg:
        return vendors_arg.split(',')
    return [vendors_arg]

def main():
    parser = argparse.ArgumentParser(description='Database Benchmark Runner')
    parser.add_argument('benchmark_name', help='Name of the benchmark to run')
    parser.add_argument('--creds', dest='creds_file', 
                       default='../../config/credentials/credentials.json',
                       help='Path to credentials file')
    parser.add_argument('--vendors', required=True,
                       help='Comma-separated list of vendors to benchmark (e.g., snowflake,firebolt)')
    parser.add_argument('--pool-size', type=int, default=5, 
                       help='Connection pool size')
    parser.add_argument('--concurrency', type=int, default=1, 
                       help='Concurrent queries')
    parser.add_argument('--concurrency-duration-s', type=int, default=60,
                       help='The duration in seconds to use for each concurrency benchmark')
    parser.add_argument('--seed', type=int, default=1,
                       help='The seed of the random number generator for reproducibility')
    parser.add_argument('--output-dir', default='benchmark_results', 
                       help='Output directory')
    parser.add_argument('--execute-setup', action='store_true', 
                       help='Flag to execute setup before running the benchmark')

    args = parser.parse_args()
    setup_logging()
    logger = logging.getLogger(__name__)

    try:
        # Validate benchmark exists
        benchmark_path = validate_benchmark(args.benchmark_name)

        # Parse vendors
        vendors = parse_vendors(args.vendors)
        logger.info(
            f"Running sequential benchmark '{args.benchmark_name}' for vendors: {vendors}"
        )

        sequential_runner = BenchmarkRunner(
            benchmark_name=args.benchmark_name,
            creds_file=args.creds_file,
            vendors=vendors,
            pool_size=args.pool_size,
            concurrency=1,
            output_dir=args.output_dir,
            benchmark_path=benchmark_path,
            execute_setup=args.execute_setup,
        )

        results = sequential_runner.run_benchmark()
        if not results:
            logger.error("No results were generated from the sequential benchmark")
            return

        logger.info(f"Sequential benchmark results saved to: {args.output_dir}")

        if args.concurrency == 1:   # if concurrency is 1, sequential run was enough, we can exit
            return

        # Run the concurrency benchmarks for one vendor at a time, one after another
        for vendor in vendors:
            logger.info(
                f"Running concurrency benchmark '{args.benchmark_name}' for {args.concurrency_duration_s} seconds for vendor: {vendor}"
            )
            runner = ConcurrentBenchmarkRunner(
                benchmark_name=args.benchmark_name,
                creds_file=args.creds_file,
                vendor=vendor,
                concurrency=args.concurrency,
                benchmark_duration_secs=args.concurrency_duration_s,
                output_dir=args.output_dir,
                benchmark_path=benchmark_path,
                seed=args.seed,
            )
            runner.run_benchmark()
            logger.info(
                f"Concurrency benchmark results of {vendor} saved to: {args.output_dir}"
            )

    except ValueError as e:
        logger.error(f"Configuration error: {str(e)}")
        exit(1)
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        exit(1)


if __name__ == "__main__":
    main()