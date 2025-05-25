import pandas as pd
import numpy as np
from statsmodels.tsa.statespace.sarimax import SARIMAX
import matplotlib.pyplot as plt
from datetime import datetime
import os

# Path to consolidated data
file_path = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Silver Currency\Consolidated_Currency.csv"

# Output folder and file name (updated as requested)
today_str = datetime.now().strftime("%Y-%m-%d")
output_folder = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Silver Currency"
output_file = f"Forecast_{today_str}.csv"
output_path = os.path.join(output_folder, output_file)

# Ensure output directory exists
os.makedirs(output_folder, exist_ok=True)

# Read data
df = pd.read_csv(file_path, parse_dates=['Date'])

# Prepare list to collect all forecasts
all_forecasts = []

# Loop through all unique currencies
for currency_name in df['Currency Full Name'].unique():
    currency_df = df[df['Currency Full Name'] == currency_name].sort_values('Date')
    if currency_df.empty or len(currency_df) < 10:
        # Skip if not enough data for forecasting
        continue

    # Set Date as index
    currency_df = currency_df.set_index('Date')
    y = currency_df['Currency Rate']

    try:
        # Fit SARIMAX model (simple ARIMA, no seasonality)
        model = SARIMAX(y, order=(1,1,1), enforce_stationarity=False, enforce_invertibility=False)
        model_fit = model.fit(disp=False)

        # Forecast next 5 days
        forecast = model_fit.get_forecast(steps=5)
        forecast_index = pd.date_range(y.index[-1] + pd.Timedelta(days=1), periods=5, freq='D')
        forecast_mean = forecast.predicted_mean
        forecast_ci = forecast.conf_int(alpha=0.05)  # 95% confidence interval

        # Prepare results
        forecast_df = pd.DataFrame({
            'Currency Full Name': currency_name,
            'Date': forecast_index,
            'Forecast': forecast_mean.values,
            'Lower 95%': forecast_ci.iloc[:, 0].values,
            'Upper 95%': forecast_ci.iloc[:, 1].values,
            'Probability': [0.95]*5,  # 95% confidence for each forecast
            'Version': [os.path.splitext(os.path.basename(output_file))[0]]*5  # Name without extension
        })

        all_forecasts.append(forecast_df)
    except Exception as e:
        print(f"Forecast failed for {currency_name}: {e}")

# Concatenate all forecasts and save to file
if all_forecasts:
    result_df = pd.concat(all_forecasts, ignore_index=True)
    result_df.to_csv(output_path, index=False)
    print(f"Forecasts saved to {output_path}")
else:
    print("No forecasts generated.")