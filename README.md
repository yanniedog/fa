
# FlightAware Contribution Monitor

Script to discover how much of your ADSB receiver data FlightAware are actually using.

## Purpose

By running this application, you get detailed insight into your ADS-B contributions to FlightAware. This is valuable for tracking performance and troubleshooting issues.

## Overview

The application comprises seven main components:

- **Configuration File (config.me)**: Contains settings like FlightAware username.
- **Startup Script (start.sh)**: Initiates the application and runs the Python scripts.
- **FA Stats (step1-fa-stats-page.py)**: Scrapes statistics from FlightAware.
- **Download Tracklogs (step2-download-tracklog-htmls.py)**: Downloads track logs.
- **Scrape Local HTMLs (step3-scrape-local-htmls.py)**: Parses downloaded HTML track logs.
- **Build Final Report (step4-build-final-report.py)**: Compiles data into a final report.
- **Erase Temp Files (step5-erase-temp-files.py)**: Deletes temporary files.

## Requirements
- Raspberry Pi4 running Raspbian OS
- FlightAware ADSB account

## Dependencies (automatically installed)
- sudo apt update && sudo apt upgrade
- Python 3.x
- Selenium WebDriver
- BeautifulSoup
- Additional Python libraries (e.g., requests, csv, re)
- sudo apt update

## Installation

1) `wget https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main/install-fa-tracklog-contribution.sh`
2) `chmod +x install-fa-tracklog-contribution.sh`
3) `./install-fa-tracklog-contribution.sh`

## Configuration

1. Open `config.me` in a text editor.
2. Edit the settings to match your FlightAware username and other necessary parameters.

## Usage

1. Open a terminal window.
2. Navigate to the application directory.
3. Make `start.sh` executable if it isn't: `chmod +x start.sh`.
4. Run `start.sh` to initiate the application: `./start.sh`.

## Uninstallation
- Delete the installation directory (rm -r /home/pi/{installation directory}
- Delete installation script file

![Screenshot 2023-10-17 181904](https://github.com/yanniedog/flightaware-contribution/assets/25560742/46a896b9-f407-4c03-8133-592dea17dcba)
