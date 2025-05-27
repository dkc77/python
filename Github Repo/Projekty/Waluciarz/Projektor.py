import pandas as pd
from prophet import Prophet
from datetime import datetime
import os
import warnings

# Path to consolidated data
file_path = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Silver Currency\Consolidated_Currency.csv"

# Output folder and file name
today_str = datetime.now().strftime("%Y-%m-%d")
output_folder = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Forecaster"
output_file = f"Forecast_{today_str}.csv"
output_path = os.path.join(output_folder, output_file)

# Ensure output directory exists
os.makedirs(output_folder, exist_ok=True)

# Read data
df = pd.read_csv(file_path, parse_dates=['Date'])

# Fill NaN values in 'Currency Rate' with 0 (or another appropriate value)
df['Currency Rate'] = df['Currency Rate'].fillna(0)

# Prepare list to collect all forecasts
all_forecasts = []

currency_list = df['Currency Full Name'].unique()
for currency_name in currency_list:
    currency_df = df[df['Currency Full Name'] == currency_name].sort_values('Date')
    if currency_df.empty or len(currency_df) < 10:
        continue

    # Prophet expects columns: ds (date), y (value)
    prophet_df = currency_df.rename(columns={'Date': 'ds', 'Currency Rate': 'y'})[['ds', 'y']]

    try:
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            model = Prophet()
            model.fit(prophet_df)

        # Forecast next 5 days
        future = model.make_future_dataframe(periods=5, freq='D')
        forecast = model.predict(future)
        forecast_tail = forecast.tail(5)  # Only the forecasted days

        forecast_df = pd.DataFrame({
            'Currency Full Name': currency_name,
            'Date': forecast_tail['ds'].values,
            'Forecast': forecast_tail['yhat'].values,
            'Lower 95%': forecast_tail['yhat_lower'].values,
            'Upper 95%': forecast_tail['yhat_upper'].values,
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