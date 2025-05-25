import os
import pandas as pd
import shutil

src_folder = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Raw\NBP"
dst_folder = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Converter"

# Ensure destination folder exists
os.makedirs(dst_folder, exist_ok=True)

for filename in os.listdir(src_folder):
    src_path = os.path.join(src_folder, filename)
    dst_path = os.path.join(dst_folder, filename)
    
    # Copy file to destination
    shutil.copy2(src_path, dst_path)
    
    # Read and transpose data
    df = pd.read_csv(dst_path, encoding="cp1250", delimiter=";")
    # Assume first column is date, rest are currencies
    df_melted = df.melt(id_vars=[df.columns[0]], var_name='Currency', value_name='Currency Rate')
    df_melted.rename(columns={df.columns[0]: 'Date'}, inplace=True)
    
    # Reorder columns to match: Date, Currency, Currency Rate
    df_melted = df_melted[['Date', 'Currency', 'Currency Rate']]
    
    # Convert Date to datetime format
    df_melted['Date'] = pd.to_datetime(df_melted['Date'], errors='coerce')
    df_melted = df_melted.dropna(subset=['Date'])
    
    # Convert Currency Rate to decimal (float), remove rows that cannot be converted
    df_melted['Currency Rate'] = pd.to_numeric(df_melted['Currency Rate'].str.replace(',', '.'), errors='coerce')
    df_melted = df_melted.dropna(subset=['Currency Rate'])
    
    # Remove digits from Currency column, keep only currency name
    # df_melted['Currency'] = df_melted['Currency'].str.replace(r'\d+', '', regex=True).str.strip()

    # Add new columns: Target Currency (string, "PLN") and Target Value Currency (decimal, 1)
    df_melted['Target Currency'] = 'PLN'
    df_melted['Target Value Currency'] = 1.0

    # Save transposed data (overwrite file)
    df_melted.to_csv(dst_path, index=False)

print("Files copied and transposed successfully.")