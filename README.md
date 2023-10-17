# flightaware-contribution
Script to discover how much of your ADSB receiver data FlightAware are actually using

**Purpose**
By running this application, you get a detailed insight into your ADS-B contributions to FlightAware, conveniently processed and summarized for you. 
This could be valuable for tracking your contribution performance over time or for troubleshooting any issues with your ADS-B setup.

**Installation:**

1) ```wget https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main/install-fa-tracklog-contribution.sh```
2) ```chmod +x install-fa-tracklog-contribution.sh```
3) ```./install-fa-tracklog-contribution.sh```


**Overview**
The application comprises seven main components:

- Configuration File (config.me): Contains key-value pairs for settings like your FlightAware username.
- Startup Script (start.sh): Shell script that initiates the application and orchestrates the Python scripts.
- FA Stats (step1-fa-stats-page.py): Scrapes statistics from FlightAware.
- Download Tracklogs (step2-download-tracklog-htmls.py): Downloads track logs in HTML format.
- Scrape Local HTMLs (step3-scrape-local-htmls.py): Parses downloaded HTML track logs.
- Build Final Report (step4-build-final-report.py): Compiles gathered data into a final report.
- Erase Temp Files (step5-erase-temp-files.py): Deletes temporary files created during the process.

**Compatibility:**
- Python 3.x
- Selenium WebDriver
- Additional Python libraries as specified in each Python script (e.g., requests, csv, re)
- FlightAware account

_Note: This has only been tested on a Raspberry Pi 4B+ running Raspbian OS_
