# Script Name: step2-download-tracklog-htmls.py

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import os
import datetime

# Function to read configuration from config.me
def read_config(config_file_path):
    config = {}
    if os.path.exists(config_file_path):
        with open(config_file_path, 'r') as f:
            for line in f:
                line = line.strip()
                # Ignore lines starting with '#' as they are comments
                if line and not line.startswith("#"):
                    parts = line.split('=')
                    if len(parts) == 2:
                        key, value = parts
                        config[key] = value.strip('"')
    return config

# Load configuration from config.me in the parent directory
config_file_path = os.path.join(os.path.dirname(__file__), "..", "config.me")  # Use the parent directory
config = read_config(config_file_path)

# Check if the installation directory is defined in the config
if 'installation_directory' not in config:
    print("Error: 'installation_directory' not defined in config.me.")
    exit(1)

# Initialize Chrome options
chrome_options = Options()
chrome_options.add_argument("--headless")
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")

# Function to scrape and save tracklog HTML for each URL
def scrape_and_save_tracklog_html():
    # Get the installation directory from the config
    installation_directory = config.get('installation_directory')

    # Updated file path to be in the temp folder
    tracklog_urls_file = os.path.join(installation_directory, 'temp', "tracklog_urls.tmp")

    # Check if the tracklog URLs file exists
    if not os.path.exists(tracklog_urls_file):
        print("Error: tracklog_urls.tmp file not found.")
        exit(1)

    # Read the URLs from the text file in the temp folder
    with open(tracklog_urls_file, "r") as f:
        tracklog_urls = f.readlines()

    for url in tracklog_urls:
        driver = webdriver.Chrome(options=chrome_options)
        driver.get(url.strip())  # Remove any leading/trailing whitespace or newlines

        # Extract the flight code from the URL
        final_url = driver.current_url
        flight_code = final_url.split("/")[5]

        # Save the HTML content to the new directory
        output_dir = os.path.join(installation_directory, 'temp')
        file_name = f"tracklog - {flight_code} - {datetime.datetime.now().strftime('%Y%m%d')}.html"
        file_path = os.path.join(output_dir, file_name)

        with open(file_path, 'w', encoding='utf-8') as file:
            file.write(driver.page_source)

        print(f"Saved {file_name}")

        driver.quit()

# Run the scraper function
scrape_and_save_tracklog_html()
