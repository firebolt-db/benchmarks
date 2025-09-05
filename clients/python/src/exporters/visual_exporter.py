import os
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from .base import BenchmarkExporter
from typing import Dict, Any
import distinctipy

class VisualExporter(BenchmarkExporter):
    def __init__(self, output_dir: str):
        self.output_dir = output_dir

    def export(self, results: Dict[str, Any], output_dir: str) -> None:
        """Generate a visualization for benchmark results showing average execution time per vendor for each query."""
        # Prepare execution_times dictionary
        execution_times = {}
        query_names = []

        # Collect data for plotting
        for vendor, vendor_results in results.items():
            execution_times[vendor] = []
            for result in vendor_results:
                query_names.append(result['query_name'])
                execution_times[vendor].append(result['execution_time'])

        # Ensure unique query names
        query_names = list(dict.fromkeys(query_names))

        # Calculate average execution times
        avg_execution_times = {vendor: [] for vendor in execution_times.keys()}
        for query in query_names:
            for vendor in execution_times.keys():
                # Filter results for the current vendor and query
                filtered_times = [result['execution_time'] for result in results[vendor] if result['query_name'] == query]

                # # Calculate average if there are execution times
                avg_time = np.mean(filtered_times)
                avg_execution_times[vendor].append(avg_time)

        # Define a color map for each vendor using RGB values
        # vendor_colors = {
        #     'firebolt': '#f72a30',
        #     'redshift': '#E47911',
        #     'snowflake': '#249edc',
        #     'bigquery': '#008000' # green cause their color it too close to SF :-)
        # }
        colors = distinctipy.get_colors(len(avg_execution_times))
        colors[0]
        vendor_colors = {vendor: color for vendor, color in zip(avg_execution_times.keys(), colors)}

        # Plotting
        plt.figure(figsize=(10, 6))

        # Set the bar width
        bar_width = 0.2
        index = np.arange(len(query_names))

        # Plot each vendor's average execution time with specified RGB colors
        for i, vendor in enumerate(avg_execution_times.keys()):
            plt.bar(index + i * bar_width, avg_execution_times[vendor], bar_width, label=vendor, color=distinctipy.distinctipy.get_hex(vendor_colors.get(vendor, (0.2, 0.2, 0.2))))

        # Set the x-ticks to the query names
        plt.xlabel('Queries')
        plt.ylabel('Average Execution Time (seconds)')
        plt.title('Average Execution Time per Vendor for Each Query')
        plt.xticks(index + bar_width, query_names)
        plt.legend()  # Add a legend to identify vendors
        plt.tight_layout()

        visual_file_path = os.path.join(output_dir, 'visual_results.pdf')
        plt.savefig(visual_file_path, dpi=400)
        plt.close()
        print(f"Visualization saved to {visual_file_path}")
