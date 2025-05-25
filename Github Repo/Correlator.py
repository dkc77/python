import pandas as pd

# Path to the consolidated file
file_path = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Silver Currency\Consolidated_Currency.csv"

# Read the data
df = pd.read_csv(file_path, parse_dates=['Date'])

# Pivot the table: rows=Date, columns=Currency, values=Currency Rate
pivot_df = df.pivot_table(index='Date', columns='Currency', values='Currency Rate')

# Drop rows with any missing values to ensure fair correlation calculation
pivot_df = pivot_df.dropna()

# Calculate correlation matrix
correlation_matrix = pivot_df.corr()

# Show the correlation matrix
print("Correlation matrix between currencies:")
print(correlation_matrix)

# Optionally, save to CSV
correlation_matrix.to_csv(r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Silver Currency\Currency_Correlation.csv")