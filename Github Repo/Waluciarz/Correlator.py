import pandas as pd
import os

# Path to the consolidated file
file_path = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Silver Currency\Consolidated_Currency.csv"

# Output folder and file name
output_folder = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Korelator"
output_file = "Correlation_2025.csv"
output_path = os.path.join(output_folder, output_file)

# Ensure output directory exists
os.makedirs(output_folder, exist_ok=True)

# Read the data
df = pd.read_csv(file_path, parse_dates=['Date'])

# Filter for 2025 only
df_2025 = df[df['Date'].dt.year == 2025]

# Pivot the table: rows=Date, columns=Currency, values=Currency Rate
pivot_df = df_2025.pivot_table(index='Date', columns='Currency', values='Currency Rate')

# Drop rows with any missing values to ensure fair correlation calculation
pivot_df = pivot_df.dropna()

# Calculate correlation matrix
correlation_matrix = pivot_df.corr()

# Rename index and columns to avoid duplicate names
correlation_matrix.index.name = 'Currency_A'
correlation_matrix.columns.name = 'Currency_B'

# Stack the matrix to get pairs, remove self-correlation and duplicates
corr_pairs = correlation_matrix.stack().reset_index()
corr_pairs.columns = ['Currency_A', 'Currency_B', 'Correlation']

# Remove self-correlation
corr_pairs = corr_pairs[corr_pairs['Currency_A'] != corr_pairs['Currency_B']]

# To avoid duplicate pairs (A-B and B-A), sort and drop duplicates
corr_pairs['pair'] = corr_pairs.apply(lambda row: '-'.join(sorted([row['Currency_A'], row['Currency_B']])), axis=1)
corr_pairs = corr_pairs.drop_duplicates(subset=['pair'])

# Map currency codes to full names using the original dataframe
currency_name_map = df.set_index('Currency')['Currency Full Name'].to_dict()
corr_pairs['Currency_A_Name'] = corr_pairs['Currency_A'].map(currency_name_map)
corr_pairs['Currency_B_Name'] = corr_pairs['Currency_B'].map(currency_name_map)

# Map currency codes to full names using the original dataframe
currency_name_map = df.set_index('Currency')['Currency Full Name'].to_dict()
corr_pairs['Currency_A_Name'] = corr_pairs['Currency_A'].map(currency_name_map)
corr_pairs['Currency_B_Name'] = corr_pairs['Currency_B'].map(currency_name_map)

# Get top 10 most correlated pairs (absolute value, descending)
top10 = corr_pairs.reindex(corr_pairs['Correlation'].abs().sort_values(ascending=False).index).head(10)

print("Top 10 most correlated currency pairs for 2025:")
print(top10[['Currency_A_Name', 'Currency_B_Name', 'Correlation']])

# Save the results to a CSV file
top10.to_csv(output_path, index=False)
print(f"Correlation results saved to {output_path}")