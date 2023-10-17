#!/bin/bash

# Custom launch message
echo "FlightAware ADS-B contribution monitor has been launched"

# Filename: start.sh
# Run this script to start the application

# Specify the name of the configuration file
config_file="config.me"

# Check if the configuration file exists
if [ -f "$config_file" ]; then
    # Load configuration settings from config.me
    source "$config_file"
else
    # Print an error message and exit if the config file is not found
    echo "Error: Config file not found. Please make sure config.me is in the same directory."
    exit 1
fi

# Create a variable for the temp folder
temp_folder="$installation_directory/temp"

# Check if the temp folder exists, and create it if not
if [ ! -d "$temp_folder" ]; then
  mkdir -p "$temp_folder"
fi

# Create a variable for the airport-library folder
airport_library_folder="$installation_directory/backend/airport-library"

# Check if the airport-library folder exists, and create it if not
if [ ! -d "$airport_library_folder" ]; then
  mkdir -p "$airport_library_folder"
fi

# Check if the icao2iata.csv file exists, and download it if not
if [ ! -f "$installation_directory/backend/airport-library/icao2iata.csv" ]; then
  echo "Downloading airport data..."
  wget -O "$installation_directory/backend/airport-library/icao2iata.csv" "https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main/icao2iata.csv"
  echo "Airport data downloaded successfully."
fi

# Initialize variables
cycles=0
start_time=$(date +"%F %T")
elapsed_time="0s"
elapsed_time_formatted="0h 0m 0s"

# Display current configuration from config.me
echo -e "\nCurrent configuration (in config.me):"
echo "  Installation Directory: $installation_directory"
echo "  FlightAware Username: $username"
echo "  Searching for the term \"$reporting_facility\" within FlightAware's tracklog pages"
echo "  Each cycle repeats after: $loop_frequency seconds"
echo "------------------------------------------"

# Enter a loop to execute Python scripts continuously
while true; do
  # Update cycle count and elapsed time
  cycles=$((cycles + 1))
  current_time=$(date +"%F %T")
  elapsed_time=$(($(date -d "$current_time" +%s) - $(date -d "$start_time" +%s)))
  elapsed_time_formatted=$(date -u -d @"$elapsed_time" +'%Hh %Mm %Ss')

  # Change to the installation directory
  cd "$installation_directory/backend" || { echo "Directory not found. Exiting..."; exit 1; }

  # Execute Python scripts with descriptions
  echo -e "\nCycle $cycles (Started at: $start_time, Elapsed Time: $elapsed_time_formatted)..."
  echo -e "Running step1-fa-stats-page.py..."
  python3 step1-fa-stats-page.py || echo -e "  Error executing step1-fa-stats-page.py\n"

  echo -e "Running step2-download-tracklog-htmls.py..."
  python3 step2-download-tracklog-htmls.py || echo -e "  Error executing step2-download-tracklog-htmls.py\n"

  echo -e "Running step3-scrape-local-htmls.py..."
  python3 step3-scrape-local-htmls.py || echo -e "  Error executing step3-scrape-local-htmls.py\n"

  echo -e "Running step4-build-final-report.py..."
  python3 step4-build-final-report.py || echo -e "  Error executing step4-build-final-report.py\n"

  echo -e "Running step5-erase-temp-files.py..."
  python3 step5-erase-temp-files.py || echo -e "  Error executing step5-erase-temp-files.py\n"

  # Sleep for the specified loop frequency and show a countdown timer
  for i in $(seq "$loop_frequency" -1 1); do
    echo -n -e "  Sleeping for $i more seconds before starting the next cycle... (Cycle $cycles)\r"
    sleep 1
  done
done
