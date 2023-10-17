# Script Name: step1-fa-stats-page.py

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
import os
from datetime import datetime
import csv

# Load configuration from config.me in the parent directory
config_file_path = os.path.join(os.path.dirname(__file__), "..", "config.me")
config = {}
if os.path.exists(config_file_path):
    with open(config_file_path, "r") as f:
        for line in f:
            if "=" in line:
                key, value = line.strip().split("=", 1)
                config[key] = value.strip('"')
else:
    print("Error: config.me file not found in the parent directory of this script.")
    exit(1)

username = config.get('username', None)
if username is None:
    print("Error: 'username' is not specified in the config file.")
    exit(1)

installation_directory = config['installation_directory']

chrome_options = Options()
chrome_options.add_argument("--headless")
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")

def scrape_data():
    driver = webdriver.Chrome(options=chrome_options)
    driver.get(f"https://flightaware.com/adsb/stats/user/{username}")

    # Continue with the scraping process
    flight_rows = driver.find_elements(By.XPATH, ".//div[contains(@class, 'positionTableCellFlight')]/span/a[not(contains(@href, 'tracklog'))]")
    
    data = []
    for flight_row in flight_rows:
        tracklog_link = flight_row.get_attribute("href").replace('/live/flight/id/', '/live/flight/id/') + "/tracklog"
        data.append(tracklog_link)

    temp_folder = os.path.join(installation_directory, 'temp')
    os.makedirs(temp_folder, exist_ok=True)  # Create 'temp' directory if it doesn't exist
    file_name = os.path.join(temp_folder, f"tracklog_links_{datetime.now().strftime('%d%m%y_%H%M%S')}.csv")
    
    with open(file_name, 'w', newline='') as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(["Tracklog Links"])
        for link in data:
            writer.writerow([link])

    # Save tracklog URLs to the specified text file
    tracklog_urls_file = os.path.join(temp_folder, "tracklog_urls.tmp")
    with open(tracklog_urls_file, 'w') as f:
        f.write("\n".join(data))
    
    driver.quit()

# Run once
scrape_data()
