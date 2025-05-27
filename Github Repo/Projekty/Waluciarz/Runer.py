import subprocess
import sys
import os

# Define script paths (now in the same directory as Runer.py)
base_dir = os.path.dirname(os.path.abspath(__file__))
extractor_path = os.path.join(base_dir, 'Extractor NBP.py')
converter_path = os.path.join(base_dir, 'Converter NBP.py')

# Run Extractor NBP.py
print("Running Extractor NBP.py...")
try:
    result = subprocess.run([sys.executable, extractor_path], check=True, capture_output=True, text=True)
    print(result.stdout)
    print(result.stderr)
except subprocess.CalledProcessError as e:
    print("Extractor NBP.py failed with error:")
    print(e.stdout)
    print(e.stderr)
    sys.exit(1)

# Run Converter NBP.py
print("Running Converter NBP.py...")
subprocess.run([sys.executable, converter_path], check=True)

print("Sequence completed.")