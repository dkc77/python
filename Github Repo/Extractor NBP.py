import requests
import os

save_dir = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Raw\NBP"
os.makedirs(save_dir, exist_ok=True)

start_year = 2020
end_year = 2025  # inclusive

for year in range(start_year, end_year + 1):
    url = f"https://static.nbp.pl/dane/kursy/Archiwum/archiwum_tab_a_{year}.csv"
    filename = os.path.join(save_dir, f"archiwum_tab_a_{year}.csv")
    try:
        response = requests.get(url)
        response.raise_for_status()
        with open(filename, "wb") as f:
            f.write(response.content)
        print(f"File downloaded to: {filename}")
    except requests.exceptions.RequestException as e:
        print(f"Failed to download for year {year}: {e}")