#!/bin/bash

# Function to download a file from GitHub
download_file () {
  wget -O "$2" "$1"
}

# Default installation directory
default_installation_directory="fa-tracklog-contribution"

# Ask user for installation directory
read -rp "Please specify the installation_directory [$default_installation_directory]: " installation_directory
installation_directory=${installation_directory:-$default_installation_directory}

# Create installation directory if it doesn't exist
mkdir -p "$installation_directory"

# Create 'backend' subdirectory
mkdir -p "$installation_directory/backend"

# Download files into installation directory
download_file "https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main/start.sh" "$installation_directory/start.sh"
download_file "https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main/config.me" "$installation_directory/config.me"

# Make start.sh executable
chmod +x "$installation_directory/start.sh"

# Download files into 'backend' subdirectory
download_file "https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main/step1-fa-stats-page.py" "$installation_directory/backend/step1-fa-stats-page.py"
download_file "https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main/step2-download-tracklog-htmls.py" "$installation_directory/backend/step2-download-tracklog-htmls.py"
download_file "https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main/step3-scrape-local-htmls.py" "$installation_directory/backend/step3-scrape-local-htmls.py"
download_file "https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main/step4-build-final-report.py" "$installation_directory/backend/step4-build-final-report.py"
download_file "https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main/step5-erase-temp-files.py" "$installation_directory/backend/step5-erase-temp-files.py"

# Ask user for FlightAware username
read -rp "Please enter your FlightAware username: " username

# Ask user for Reporting Facility identifier
read -rp "Please enter the term that will identify your ADS-B receiver within the Receiver Facility column of FlightAware tracklog pages: " reporting_facility

# Update config.me file
sed -i "s|username=\".*\"|username=\"$username\"|g" "$installation_directory/config.me"
sed -i "s|reporting_facility=\".*\"|reporting_facility=\"$reporting_facility\"|g" "$installation_directory/config.me"
sed -i "s|installation_directory=\".*\"|installation_directory=\"$installation_directory\"|g" "$installation_directory/config.me"

echo "Installation completed."
echo "Please confirm your configuration in $installation_directory/config.me."
echo "For additional guidance, refer to the usage guide available as remarks in the config.me file."
echo "After confirming, you can start the application by running 'start.sh' from the $installation_directory directory."