import requests
import os

url = "https://static.nbp.pl/dane/kursy/Archiwum/archiwum_tab_a_2025.csv"
save_dir = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Sample"
filename = os.path.join(save_dir, "archiwum_tab_a_2025.csv")

os.makedirs(save_dir, exist_ok=True)

response = requests.get(url)
response.raise_for_status()

with open(filename, "wb") as f:
    f.write(response.content)

print(f"File downloaded to: {filename}")