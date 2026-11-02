import pandas as pd
from pathlib import Path

def merge_files_to_data_mart(source_folders, output_file_path, file_pattern="*.csv"):
    """
    Merges files from specified source folders into a single output file.

    Args:
        source_folders (list): A list of strings, where each string is the path
                               to a source folder.
        output_file_path (str): The full path (including filename) for the
                                merged output file.
        file_pattern (str, optional): The glob pattern to match files in the
                                      source folders. Defaults to "*.csv".
    """
    all_dataframes = []
    output_path = Path(output_file_path)

    # Ensure the output directory exists
    output_path.parent.mkdir(parents=True, exist_ok=True)

    print(f"Starting file merge process...")
    print(f"Output will be saved to: {output_path}")

    for folder_path_str in source_folders:
        folder_path = Path(folder_path_str)
        if not folder_path.is_dir():
            print(f"Warning: Source folder not found or is not a directory: {folder_path}")
            continue

        print(f"\nProcessing files in folder: {folder_path}")
        files_found = list(folder_path.glob(file_pattern))

        if not files_found:
            print(f"No files matching '{file_pattern}' found in {folder_path}.")
            continue

        for file_path in files_found:
            try:
                print(f"  Reading file: {file_path.name}")
                if file_path.suffix.lower() == ".csv":
                    df = pd.read_csv(file_path)
                elif file_path.suffix.lower() in [".xls", ".xlsx"]:
                    df = pd.read_excel(file_path)
                else:
                    print(f"    Skipping unsupported file type: {file_path.name}")
                    continue

                # Check if 'Forecast' column exists and 'Currency Rate' is missing
                if 'Forecast' in df.columns and 'Currency Rate' not in df.columns:
                    print(f"    Copying 'Forecast' to 'Currency Rate' for {file_path.name}")
                    df['Currency Rate'] = df['Forecast']

                all_dataframes.append(df)
                print(f"    Successfully read {file_path.name} ({len(df)} rows)")
            except Exception as e:
                print(f"    Error reading file {file_path.name}: {e}")

    if not all_dataframes:
        print("\nNo dataframes were read. Output file will not be created.")
        return

    print(f"\nConcatenating {len(all_dataframes)} dataframes...")
    try:
        merged_df = pd.concat(all_dataframes, ignore_index=True)
        print(f"Concatenation successful. Total rows in merged data: {len(merged_df)}")

        # Save the merged dataframe
        # Determine save function based on output file extension
        if output_path.suffix.lower() == ".csv":
            merged_df.to_csv(output_path, index=False)
            print(f"\nSuccessfully merged data saved to: {output_path}")
        elif output_path.suffix.lower() in [".xls", ".xlsx"]:
            merged_df.to_excel(output_path, index=False)
            print(f"\nSuccessfully merged data saved to: {output_path}")
        elif output_path.suffix.lower() == ".parquet":
            merged_df.to_parquet(output_path, index=False)
            print(f"\nSuccessfully merged data saved to: {output_path}")
        else:
            print(f"\nUnsupported output file type: {output_path.suffix}. Please use .csv, .xlsx, or .parquet.")
            print("Attempting to save as CSV by default.")
            default_output_csv = output_path.with_suffix(".csv")
            merged_df.to_csv(default_output_csv, index=False)
            print(f"Successfully merged data saved to: {default_output_csv}")

    except Exception as e:
        print(f"Error during concatenation or saving merged file: {e}")

if __name__ == "__main__":
    # Define your source folders
    # Using raw strings (r"...") for Windows paths to handle backslashes correctly
    source_folder_1 = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Silver Currency"
    source_folder_2 = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Forecaster"
    
    source_folders_list = [source_folder_1, source_folder_2]

    # Define your output file path (including the desired filename and extension)
    # For example, saving as a CSV file:
    output_file = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Data Marts\Data Mart.csv"
    # Or if you prefer Excel:
    # output_file = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Data Marts\Data Mart.xlsx"
    # Or Parquet for better performance with large datasets:
    # output_file = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Data Marts\Data Mart.parquet"


    # Specify the pattern for files to merge (e.g., "*.csv", "*.xlsx", "data_*.txt")
    # If your files are Excel files, change this to "*.xlsx" or "*.xls"
    file_pattern_to_merge = "*.csv" 
    # If you want to merge both CSV and Excel files, you might need to run the script twice
    # or modify it to handle multiple patterns in one go. For simplicity, this example
    # focuses on one pattern at a time but can read both if they match a generic pattern like "*.*"
    # and then checks extensions.

    merge_files_to_data_mart(source_folders_list, output_file, file_pattern_to_merge)

    # Example for merging Excel files (if you have them)
    # print("\n--- Merging Excel files (if any) ---")
    # output_excel_file = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Waluty\Data Marts\merged_excel_data.xlsx"
    # merge_files_to_data_mart(source_folders_list, output_excel_file, file_pattern="*.xlsx")
