# Benchmark Tool

## Description

This project provides a benchmarking tool for various data warehouse vendors, allowing users to compare performance across different systems. The tool supports multiple vendors, including Snowflake, Firebolt, and BigQuery, and can execute custom SQL queries for benchmarking.

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

## Credential Files

To connect to the data warehouse vendors, you need to provide a single credentials file located at `config/credentials/credentials.json`. The expected format for this file is as follows:

```json
{
    "snowflake": {
        "account": "your_account",
        "user": "your_username",
        "password": "your_password",
        "database": "your_database",
        "schema": "your_schema",
        "warehouse": "your_warehouse"
    },
    "firebolt": {
        "account": "your_account",
        "user": "your_username",
        "password": "your_password",
        "database": "your_database"
    },
    "bigquery": {
        "project_id": "your_project_id",
        "key_file": "path_to_your_service_account_key.json"
    },
     "redshift": {
        "host": "your_cluster_name.region.redshift.amazonaws.com",
        "port": 5439,
        "database": "your_database",
        "user": "your_username",
        "password": "your_password"
    },
}
```

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
python -m src.main my_benchmark --vendors snowflake,firebolt --execute-setup
```

## Flexibility in SQL File Usage

This project allows for flexibility in how SQL files are used:

- **General SQL Files**: Each benchmark folder contains a general `benchmark.sql` and `setup.sql` file that can be used for all vendors. These files contain common queries that apply to all vendors.

- **Vendor-Specific SQL Files**: If a vendor has specific requirements or optimizations, you can create a `benchmark.sql` and `setup.sql` file within the vendor's folder. If these vendor-specific files exist, they will be used instead of the general files.

This structure allows you to easily manage and execute queries that are tailored to specific vendors while still providing a common set of queries for all vendors.

## Directory Structure

```
project-root/
│
├── src/
│   ├── connectors/          # Contains connector implementations for each vendor
│   │   ├── base.py
│   │   ├── firebolt.py
│   │   ├── bigquery.py
│   │   ├── redshift.py
│   │   └── snowflake.py
│   ├── exporters/          # Contains exporter implementations for each vendor
│   │   ├── base.py
│   │   ├── csv_exporter.py
│   │   └── visual_exporter.py
│   ├── main.py              # Entry point for the benchmarking tool
│   └── runner.py            # Benchmark runner logic
│
├── benchmarks/              # Contains benchmark definitions
│   ├── sample_benchmark/
│   │   ├── benchmark.sql          # General benchmark SQL file for sample_benchmark
│   │   ├── setup.sql              # General setup SQL file for sample_benchmark
│   │   └── firebolt/
│   │       └── setup.sql          # firebolt specific setup SQL file
│   │   
│   └── FireBench/
│       ├── firebolt/
│       │   ├── benchmark.sql      # firebolt specific benchmark SQL file
│       │   └── setup.sql          # firebolt specific setup SQL file
│       │
│       └── snowflake/
│       |   ├── benchmark.sql      # snowflake specific benchmark SQL file
│       |   └── setup.sql          # snowflake specific setup SQL file
│       │
│       └── bigquery/
│       |   ├── benchmark.sql      # bigquery specific benchmark SQL file
│       |   └── setup.sql          # bigquery specific setup SQL file
│       │
│       └── redshift/
│           ├── benchmark.sql      # redshift specific benchmark SQL file
│           └── setup.sql          # redshift specific setup SQL file
│
├── tests/                   # Contains unit and integration tests
│
├── config/                  # Contains configuration files for the application
│   ├── credentials/         # Contains credential files
│   │   ├── credentials.json  # Single credentials file for all vendors (ignored)
│   │   └── sample_credentials.json  # Sample credentials file with dummy data
│   └── settings.py     
│
├── requirements.txt         # Python package dependencies
├── run_benchmark.sh        # Bash script to run the benchmark
├── LICENSE                # MIT License
└── README.md                # Project documentation
```

## Contributing

Contributions are welcome! Please follow these steps to contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes and commit them (`git commit -m 'Add new feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Create a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
