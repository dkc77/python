import os
import csv
from tabulate import tabulate  # pip install tabulate

sample_dir = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Sample"

files = [f for f in os.listdir(sample_dir) if f.lower().endswith(".csv")]

for fname in files:
    fpath = os.path.join(sample_dir, fname)
    print(f"\n=== {fname} ===")
    try:
        with open(fpath, newline='', encoding='cp1250') as csvfile:
            reader = csv.reader(csvfile, delimiter=';')
            rows = [row for _, row in zip(range(11), reader)]  # Read header + 10 rows
            if rows:
                header, *data = rows
                # Find indices for required columns
                col_names = ["data", "currency", "value"]
                indices = [header.index(col) for col in col_names if col in header]
                # Prepare transposed data
                transposed = []
                for idx, col in zip(indices, col_names):
                    col_values = [row[idx] for row in data]
                    transposed.append([col] + col_values)
                # Print transposed table
                print(tabulate(transposed, tablefmt="plain"))
            else:
                print("File is empty.")
    except Exception as e:
        print(f"Could not read {fname}: {e}")