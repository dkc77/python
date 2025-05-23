import requests
from bs4 import BeautifulSoup, Tag # Ensure Tag is imported here
import os
from urllib.parse import urljoin, urlparse
from typing import List          # For type hinting
import argparse # For command-line argument parsing

# URL of the page with CSV/XLS links
DEFAULT_PAGE_URL: str = "https://static.nbp.pl/dane/kursy/Archiwum/archiwum_tab_a.html"
DOWNLOAD_DIR: str = r"C:\Users\DominikKacprzak\OneDrive - Dominik Kacprzak Consulting\Projekt Data\Sample"

def main(page_url_for_scraping: str, download_dir: str, direct_urls: List[str] = None) -> None:
    """
    Fetches and downloads CSV files.
    Can either scrape a given URL for CSV links or download directly from provided URLs.
    :param page_url_for_scraping: The URL of the page to scrape for CSV links (used if direct_urls is None).
    :param download_dir: The directory where files will be saved.
    :param direct_urls: A list of specific URLs to download directly. Overrides scraping.
    """
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }

    # Use a session for potentially better performance and connection reuse
    with requests.Session() as session:
        session.headers.update(headers) # Apply the User-Agent to the session
        csv_links_to_download: List[str] = []

        if direct_urls:
            print(f"Direct download mode: Targeting {len(direct_urls)} provided URLs.")
            csv_links_to_download = direct_urls
        else:
            # Scraping mode
            print(f"Scraping page for CSV links: {page_url_for_scraping}")
            try:
                # It's good practice to add a timeout to prevent indefinite hanging
                response = session.get(page_url_for_scraping, timeout=15)
                response.raise_for_status()  # Check for HTTP errors

                # Parse HTML
                soup = BeautifulSoup(response.text, "html.parser")

                # --- BEGIN DEBUGGING SECTION (for scraping mode) ---
                print(f"Status Code: {response.status_code}")
                print(f"Length of response.text: {len(response.text)}")
                print(f"First 500 characters of response.text:\n{response.text[:500]}") # Uncomment to see page start

                all_a_tags = soup.find_all("a", href=True)
                print(f"Total <a> tags with href found by BeautifulSoup: {len(all_a_tags)}")

                # print("\nFirst 10 found hrefs:") # Uncomment to see sample hrefs
                # for i, tag_element in enumerate(all_a_tags[:10]):
                #     print(f"  - {tag_element.get('href')}")
                # --- END DEBUGGING SECTION ---

                # Find all links to CSV files using a list comprehension and urljoin
                csv_links_to_download = [
                    urljoin(page_url_for_scraping, str(tag_element.get("href")))
                    for tag_element in all_a_tags # Use the pre-fetched list
                    if tag_element.get("href") and str(tag_element.get("href")).lower().endswith(".csv")
                ]
                print(f"Found {len(csv_links_to_download)} CSV files to download from scraped page.")

            except requests.exceptions.RequestException as e:
                print(f"Error fetching or processing page {page_url_for_scraping}: {e}")
                csv_links_to_download = [] # Ensure list is empty on error

        if not csv_links_to_download:
            print("Download complete (no files to download).")
            return

        # Download CSV files
        os.makedirs(download_dir, exist_ok=True)
        for link in csv_links_to_download:
            try:
                # Extract a clean filename from the URL's path component
                parsed_url = urlparse(link)
                clean_basename = os.path.basename(parsed_url.path)
                if not clean_basename: # Handle cases where path might be '/' or empty
                    print(f"Warning: Could not extract a valid filename from URL path '{parsed_url.path}' for link: {link}. Skipping.")
                    continue
                filename = os.path.join(download_dir, clean_basename)
            except ValueError as e: # urlparse can raise ValueError for malformed URLs
                print(f"Warning: Malformed URL encountered '{link}': {e}. Skipping.")
                continue

            print(f"Downloading {link} -> {filename}")
            try:
                r = session.get(link)  # Use the session for downloading
                r.raise_for_status()
                with open(filename, "wb") as f:
                    f.write(r.content)
            except requests.exceptions.RequestException as e:
                print(f"Error downloading {link}: {e}")
            except IOError as e:
                print(f"Error writing file {filename}: {e}")

    print("Download complete.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Download CSV files from a specified webpage.")
    parser.add_argument(
        "--url",
        type=str,
        default=DEFAULT_PAGE_URL,
        help=(
            f"The URL of the page to scrape for CSV links. "
            f"Used if --years is not specified. Defaults to {DEFAULT_PAGE_URL}"
        )
    )
    parser.add_argument(
        "--direct-urls",
        type=str,
        nargs='+', # Accepts one or more string arguments
        help="Specific URL(s) of files to download directly (e.g., https://example.com/file1.csv https://example.com/file2.csv). Overrides --url scraping."
    )
    args = parser.parse_args()

    main(page_url_for_scraping=args.url, download_dir=DOWNLOAD_DIR, direct_urls=args.direct_urls)