import pandas as pd
import numpy as np
from statsmodels.tsa.statespace.sarimax import SARIMAX
import matplotlib.pyplot as plt
from datetime import datetime
import os
import warnings

# Optional: Uncomment if you want a progress bar
# from tqdm import tqdm

# Path to consolidated data
file_path = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Silver Currency\Consolidated_Currency.csv"

# Output folder and file name
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

# Use tqdm for progress bar if desired
currency_list = df['Currency Full Name'].unique()
# for currency_name in tqdm(currency_list, desc="Forecasting"):  # Uncomment for progress bar
for currency_name in currency_list:
    currency_df = df[df['Currency Full Name'] == currency_name].sort_values('Date')
    if currency_df.empty or len(currency_df) < 10:
        continue

    currency_df = currency_df.set_index('Date')
    y = currency_df['Currency Rate']

    try:
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            model = SARIMAX(y, order=(1,1,1), enforce_stationarity=False, enforce_invertibility=False)
            model_fit = model.fit(disp=False, maxiter=50)  # Limit iterations for speed

        forecast = model_fit.get_forecast(steps=5)
        forecast_index = pd.date_range(y.index[-1] + pd.Timedelta(days=1), periods=5, freq='D')
        forecast_mean = forecast.predicted_mean
        forecast_ci = forecast.conf_int(alpha=0.02)  # 98% confidence interval

        forecast_df = pd.DataFrame({
            'Currency Full Name': currency_name,
            'Date': forecast_index,
            'Forecast': forecast_mean.values,
            'Lower 95%': forecast_ci.iloc[:, 0].values,
            'Upper 95%': forecast_ci.iloc[:, 1].values,
            'Probability': [0.95]*5,
            'Version': [os.path.splitext(os.path.basename(output_file))[0]]*5
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