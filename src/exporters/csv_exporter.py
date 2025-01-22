import csv
import os
from .base import BenchmarkExporter
from typing import Dict, Any
import pandas as pd
from tabulate import tabulate

class CSVExporter(BenchmarkExporter):
    def export(self, results: Dict[str, Any], output_dir: str) -> None:
        """Export benchmark results to a CSV file."""
        csv_file_path = os.path.join(output_dir, 'results.csv')
        
        rows = []
        with open(csv_file_path, mode='w', newline='') as csv_file:
            fieldnames = ['vendor', 'query_name', 'execution_time', 'start_time', 'finish_time', 'concurrent_run', 'success', 'error']
            writer = csv.DictWriter(csv_file, fieldnames=fieldnames)

            writer.writeheader()
            for _, vendor_results in results.items():
                for result in vendor_results:
                    row = {
                        'vendor': result['vendor'],
                        'query_name': result['query_name'],
                        'execution_time': result['execution_time'],
                        'start_time': result['start_time'],
                        'finish_time': result['finish_time'],
                        'concurrent_run': result['concurrent_run'],
                        'success': result['success'],
                        'error': result['error'] or ''
                    }
                    writer.writerow(row)
                    rows.append(row)
        print(f"Results exported to {csv_file_path}")

        df = pd.DataFrame(rows)
        # Generate summary tables
        self._generate_summary_tables(df, output_dir)


    def _generate_summary_tables(self, df: pd.DataFrame, output_dir: str):
        # Success rate table
        success_rate = df.groupby(['vendor', 'query_name'])['success'].agg(['count', 'sum'])
        success_rate['Success Rate'] = (success_rate['sum'] / success_rate['count'] * 100).round(2)
        
        # Performance statistics table
        perf_stats = df[df['success']].groupby(['vendor', 'query_name'])['execution_time'].agg([
            'count', 'mean', 'median', 'std', 'min', 'max'
        ]).round(3)

        # Save tables
        with open(os.path.join(output_dir, 'summary_report.txt'), 'w') as f:
            f.write("Success Rate by Vendor and Query\n")
            f.write("================================\n")
            f.write(tabulate(success_rate, headers='keys', tablefmt='grid'))
            f.write("\n\nPerformance Statistics\n")
            f.write("=====================\n")
            f.write(tabulate(perf_stats, headers='keys', tablefmt='grid'))