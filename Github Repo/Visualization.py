import pandas as pd
import matplotlib.pyplot as plt

# Path to the consolidated file
file_path = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Silver Currency\Consolidated_Currency.csv"

# Read the data
df = pd.read_csv(file_path, parse_dates=['Date'])

# --- User selection ---
# List available currencies
currencies = df['Currency'].unique()
print("Available currencies:", ', '.join(currencies))

# Select currency
selected_currency = input("Enter currency to plot (e.g. USD): ").strip().upper()
if selected_currency not in currencies:
    print(f"Currency '{selected_currency}' not found. Exiting.")
    exit()

# Select date range
min_date = df['Date'].min().date()
max_date = df['Date'].max().date()
print(f"Available date range: {min_date} to {max_date}")
start_date = input(f"Enter start date (YYYY-MM-DD) [{min_date}]: ").strip() or str(min_date)
end_date = input(f"Enter end date (YYYY-MM-DD) [{max_date}]: ").strip() or str(max_date)

# Filter data
mask = (
    (df['Currency'] == selected_currency) &
    (df['Date'] >= pd.to_datetime(start_date)) &
    (df['Date'] <= pd.to_datetime(end_date))
)
subset = df[mask]

if subset.empty:
    print("No data for the selected currency and date range.")
else:
    plt.figure(figsize=(12, 6))
    plt.plot(subset['Date'], subset['Currency Rate'], label=selected_currency)
    plt.xlabel('Date')
    plt.ylabel('Currency Rate')
    plt.title(f'Currency Rate Over Time: {selected_currency}')
    plt.legend()
    plt.tight_layout()
    plt.show()