import requests
import os
from datetime import datetime
import csv # For robust CSV parsing

def download_latest_nbp_table_a_csv(target_folder):
    """
    Downloads the latest daily NBP Table A exchange rate data as a CSV file.

    Args:
        target_folder (str): The local folder path to save the CSV file.
    """
    # NBP API endpoint for the latest Table A in CSV format
    api_url = "http://api.nbp.pl/api/exchangerates/tables/A/?format=csv"
    print(f"Attempting to fetch latest Table A CSV from NBP API: {api_url}")

    try:
        csv_response = requests.get(api_url, timeout=10)
        csv_response.raise_for_status() # Raise an exception for bad status codes
        print("Successfully downloaded CSV data from the API.")
    except requests.exceptions.RequestException as e:
        print(f"Error fetching CSV from NBP API: {e}")
        return

    # Extract the date from the CSV content for the filename
    # The API CSV format is:
    # table,no,effectiveDate,tradingDate
    # "A","087/A/NBP/2024","2024-05-06","2024-05-03"
    # ...
    # We need the effectiveDate from the second line.
    
    csv_text_content = "" # Initialize to ensure it's always bound
    file_date_for_filename = datetime.now().strftime('%Y%m%d_%H%M%S') # Default fallback for filename
    try:
        # Explicitly decode the content as UTF-8 for consistency
        try:
            csv_text_content = csv_response.content.decode('utf-8')
        except UnicodeDecodeError:
            print("Warning: Failed to decode API response as UTF-8. Falling back to requests' default decoding.")
            csv_text_content = csv_response.text # Fallback to requests' auto-detected encoding

        lines = csv_text_content.strip().split('\n')
        if len(lines) >= 2:
            data_header_line = lines[1] # Second line contains the date info
            parts = data_header_line.split(',')
            if len(parts) >= 3: # effectiveDate is the third column
                effective_date_str_quoted = parts[2] # e.g., "\"2024-05-06\""
                effective_date_str = effective_date_str_quoted.strip('"') # "2024-05-06"
                
                # Convert "YYYY-MM-DD" to "YYYYMMDD" for filename
                parsed_date = datetime.strptime(effective_date_str, '%Y-%m-%d')
                file_date_for_filename = parsed_date.strftime('%Y%m%d')
                print(f"Extracted effectiveDate for filename: {file_date_for_filename}")
            else:
                print(f"Warning: CSV data line format unexpected (not enough columns: {len(parts)}). Using current timestamp for filename.")
        else:
            print(f"Warning: CSV content from API is too short (lines: {len(lines)}) to find the date. Using current timestamp for filename.")
    except Exception as e:
        print(f"Warning: Error parsing date from API response: {e}. Using current timestamp for filename.")

    # --- Parse CSV, display table to console, and prepare formatted content for file ---
    table_lines_for_file = [] # To store each line of the formatted table for file output

    print("\n--- Tabela Kursów Walut (NBP Tabela A) ---")
    table_lines_for_file.append("--- Tabela Kursów Walut (NBP Tabela A) ---")
    # Use Polish headers as requested by the user
    header_nazwa = "Nazwa waluty"
    header_kod = "Kod waluty"
    header_kurs = "Kurs średni"

    # Define column widths for formatting
    width_nazwa = 35
    width_kod = 10
    width_kurs = 15
    separator_line = "-" * (width_nazwa + width_kod + width_kurs + 6) # 2 separators " | "

    formatted_header_line = f"{header_nazwa:<{width_nazwa}} | {header_kod:<{width_kod}} | {header_kurs:<{width_kurs}}"
    print(formatted_header_line)
    table_lines_for_file.append(formatted_header_line)
    print(separator_line)
    table_lines_for_file.append(separator_line)

    actual_data_header_found = False
    data_rows_printed = 0
    try:
        # csv_text_content is already available from the date parsing section
        # DEBUG: Print a snippet of THE CSV content before parsing
        print("\nDEBUG: First 300 characters of csv_text_content for table parsing:")
        print(csv_text_content[:300])
        print("--- End of CSV snippet ---\n")

        csv_lines_iterable = csv_text_content.strip().splitlines()
        reader = csv.reader(csv_lines_iterable)
        
        # Let's be more flexible - look for any row with 3 columns that contains currency data
        # Skip the first few metadata rows and start processing data
        row_count = 0
        for row in reader:
            row_count += 1
            if not row: # Skip empty lines
                continue
            
            print(f"DEBUG: Row {row_count}: {row} (length: {len(row)})")
            
            # Skip obvious metadata rows (first few rows with table info)
            if row_count <= 4 and (len(row) < 3 or any(keyword in str(row).lower() for keyword in ['table', 'no', 'effective', 'trading'])):
                continue
                
            # Look for header row or start processing data directly
            if not actual_data_header_found:
                row_stripped = [item.strip() for item in row]
                # Check if this looks like a header row
                if (any(keyword in item.lower() for item in row_stripped for keyword in ['currency', 'code', 'mid', 'nazwa', 'kod', 'kurs']) and 
                    len(row) == 3):
                    actual_data_header_found = True
                    print(f"DEBUG: Found header row: {row}")
                    continue
                # If we have 3 columns and it doesn't look like metadata, treat it as data
                elif len(row) == 3 and not any(keyword in str(row).lower() for keyword in ['table', 'effective', 'trading']):
                    actual_data_header_found = True
                    print(f"DEBUG: No clear header found, treating row {row_count} as first data row")
                    # Don't continue, process this row as data
            
            # Process data rows
            if actual_data_header_found and len(row) == 3:
                nazwa_waluty, kod_waluty, kurs_sredni = row[0].strip(), row[1].strip(), row[2].strip()
                # Skip if this still looks like a header
                if any(keyword in nazwa_waluty.lower() for keyword in ['currency', 'nazwa', 'table']):
                    continue
                formatted_data_line = f"{nazwa_waluty:<{width_nazwa}} | {kod_waluty:<{width_kod}} | {kurs_sredni:<{width_kurs}}"
                print(formatted_data_line)
                table_lines_for_file.append(formatted_data_line)
                data_rows_printed += 1
        
        if not actual_data_header_found:
            msg = "Nie znaleziono nagłówka danych w pliku CSV."
            print(msg)
            table_lines_for_file.append(msg)
            print(f"DEBUG: All rows processed. Total rows found: {len(list(csv.reader(csv_text_content.strip().splitlines())))}")
        elif data_rows_printed == 0 and actual_data_header_found:
            msg = "Znaleziono nagłówek danych, ale brak wierszy z danymi kursów."
            print(msg)
            table_lines_for_file.append(msg)

    except csv.Error as e: # More specific exception for csv parsing issues
        msg = f"Błąd CSV podczas przetwarzania danych do tabeli: {e}"
        print(msg)
        table_lines_for_file.append(msg)
    except Exception as e:
        msg = f"Błąd podczas przetwarzania CSV do wyświetlenia tabeli: {e}"
        print(msg)
        table_lines_for_file.append(msg)
    print(separator_line)
    table_lines_for_file.append(separator_line)
    # --- End of table processing ---

    # Construct the local file path
    local_filename = "Current Rate.txt" # Changed filename and extension
    local_filepath = os.path.join(target_folder, local_filename)

    # Ensure the target directory exists
    try:
        os.makedirs(target_folder, exist_ok=True)
    except OSError as e:
        print(f"Error creating target directory {target_folder}: {e}")
        return

    # Save the formatted table content to the local file
    try:
        # Join all collected table lines into a single string with newlines
        formatted_table_string_for_file = "\n".join(table_lines_for_file)
        # Write the string to the file in text mode ('w' overwrites) with UTF-8 encoding
        with open(local_filepath, 'w', encoding='utf-8') as f:
            f.write(formatted_table_string_for_file)
        print(f"Successfully saved formatted table to: {local_filepath}")
    except IOError as e:
        print(f"Error saving the file {local_filepath}: {e}")

# --- Configuration ---
# Define the target folder path where the CSV will be saved
# Make sure this folder exists or can be created by the script
TARGET_FOLDER_PATH = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Raw\NBP"

# --- Execution ---
if __name__ == "__main__":
    download_latest_nbp_table_a_csv(TARGET_FOLDER_PATH)