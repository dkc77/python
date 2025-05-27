import pandas as pd
import matplotlib.pyplot as plt

# Path to the consolidated file
file_path = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Silver Currency\Consolidated_Currency.csv"

# Read the data
df = pd.read_csv(file_path, parse_dates=['Date'])

# Get version info (assumes all rows have the same version)
version = df['Version'].iloc[0] if 'Version' in df.columns else 'Unknown'

# List available currency names
currency_names = df['Currency Full Name'].unique()
print("Available currencies:", ', '.join(currency_names))

# Example: plot all currencies on one chart
plt.figure(figsize=(12, 6))
for currency_name in currency_names:
    subset = df[df['Currency Full Name'] == currency_name]
    plt.plot(subset['Date'], subset['Currency Rate'], label=currency_name)

plt.xlabel('Date')
plt.ylabel('Currency Rate')
plt.title(f'Currency Rates Over Time\nVersion: {version}')
plt.legend()
plt.tight_layout()
plt.show()