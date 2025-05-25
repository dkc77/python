import subprocess
import sys
import os

# Define script paths
extractor_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'Extractor NBP.py'))
converter_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'Converter NBP.py'))

# Run Extractor NBP.py
print("Running Extractor NBP.py...")
try:
    subprocess.run([sys.executable, extractor_path], check=True, capture_output=True, text=True)
except subprocess.CalledProcessError as e:
    print("Extractor NBP.py failed with error:")
    print(e.stdout)
    print(e.stderr)
    sys.exit(1)

# Run Converter NBP.py
print("Running Converter NBP.py...")
subprocess.run([sys.executable, converter_path], check=True)

print("Sequence completed.")