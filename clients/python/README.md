# Python Benchmark Client

This Python project provides a benchmarking tool for various data warehouse vendors, allowing users to compare performance across different systems. The tool supports multiple vendors, including Snowflake, Firebolt, Redshift, and BigQuery, and can execute custom SQL queries for benchmarking.

## Features

- Connect to multiple data warehouse vendors.
- Execute benchmark queries and collect results.
- Optionally execute a setup SQL file before running benchmarks.
- Easily configurable through command-line arguments.
- Supports both general SQL files for benchmarks and vendor-specific SQL files.

## Requirements

Make sure to install the required packages listed in `requirements.txt`.

```bash
pip install -r requirements.txt
```

If you have other Python-based projects, it's recommended to do this via
[venv](https://docs.python.org/3/library/venv.html) or [uv](https://github.com/astral-sh/uv).

## Usage

To run the benchmark, use the following command:

```bash
python -m src.main <benchmark_name> --vendors <vendor1,vendor2,...> [--execute-setup <True|False>]
```

### Options

- `benchmark_name`: The name of the benchmark to run.
- `--vendors`: Comma-separated list of vendors to benchmark (e.g., `snowflake,firebolt`).
- `--execute-setup`: (Optional) Set to `True` to execute the `setup.sql` file before running benchmarks. Default is `False`.
- `--pool-size`: (Optional) Connection pool size. Default is `5`.
- `--concurrency`: (Optional) Concurrency level. Default is `1`.
- `--output-dir`: (Optional) Output directory. Default is `benchmark_results`.
- `--creds`: (Optional) Path to credentials file. Default is `config/credentials/credentials.json`.

### Example

```bash
python -m src.main my_benchmark --vendors snowflake,firebolt --execute-setup True
```

## Flexibility in SQL File Usage

This project allows for flexibility in how SQL files are used:

- **General SQL Files**: Each benchmark folder contains a general `benchmark.sql` and `setup.sql` file that can be used for all vendors. These files contain common queries that apply to all vendors.

- **Vendor-Specific SQL Files**: If a vendor has specific requirements or optimizations, you can create a `benchmark.sql` and `setup.sql` file within the vendor's folder. If these vendor-specific files exist, they will be used instead of the general files.

This structure allows you to easily manage and execute queries that are tailored to specific vendors while still providing a common set of queries for all vendors.
