#!/bin/bash

# Initial Message
echo "Installing FlightAware Tracklog Contribution Monitor..."

# Check if Chromium is installed
if ! command -v chromium-browser &> /dev/null; then
    echo "Chromium is not installed. Installing Chromium..."
    sudo apt install -y chromium-browser
else
    echo "Chromium is already installed."
fi

# Update and upgrade all packages
sudo apt update
sudo apt upgrade -y

# Install required Python packages if not installed
sudo apt install -y python3-selenium python3-bs4 unzip

# Check if ChromeDriver is already installed
if ! command -v chromedriver &> /dev/null; then
    sudo apt-get install -y chromium-chromedriver
    echo "ChromeDriver installed."
else
    echo "ChromeDriver is already installed."
fi

# Get the current directory
current_directory=$(pwd)

# Default installation directory (full path)
default_installation_directory="$current_directory/fa-tracklog-contribution"

# Ask user for installation directory (full path)
read -rp "Please specify the installation directory, or just press ENTER for default [$default_installation_directory]: " installation_directory
installation_directory=${installation_directory:-$default_installation_directory}

# Create required directories
mkdir -p "$installation_directory/backend"
mkdir -p "$installation_directory/backend/airport-library"

# Function to download a file from GitHub
download_file () {
  wget -O "$2" "$1" || { echo "Error downloading $1"; exit 1; }
}

# Download essential files
download_file "https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main/start.sh" "$installation_directory/start.sh"
download_file "https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main/config.me" "$installation_directory/config.me"
download_file "https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main/icao2iata.csv" "$installation_directory/backend/airport-library/icao2iata.csv"
download_file "https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main/step1-fa-stats-page.py" "$installation_directory/backend/step1-fa-stats-page.py"
download_file "https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main/step2-download-tracklog-htmls.py" "$installation_directory/backend/step2-download-tracklog-htmls.py"
download_file "https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main/step3-scrape-local-htmls.py" "$installation_directory/backend/step3-scrape-local-htmls.py"
download_file "https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main/step4-build-final-report.py" "$installation_directory/backend/step4-build-final-report.py"
download_file "https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main/step5-erase-temp-files.py" "$installation_directory/backend/step5-erase-temp-files.py"

# Make start.sh executable
chmod +x "$installation_directory/start.sh"

# Update config.me file with user-specific info
read -rp "Please enter your FlightAware username: " username
read -rp "Please enter the term that will identify your ADS-B receiver: " reporting_facility
read -rp "Please enter the Latitude of your receiver in decimal format: " receiver_latitude
read -rp "Please enter the Longitude of your receiver in decimal format: " receiver_longitude

# Update the config.me file with the new variables
sed -i "s|username=\".*\"|username=\"$username\"|g" "$installation_directory/config.me"
sed -i "s|reporting_facility=\".*\"|reporting_facility=\"$reporting_facility\"|g" "$installation_directory/config.me"
echo "receiver_latitude=\"$receiver_latitude\"" >> "$installation_directory/config.me"
echo "receiver_longitude=\"$receiver_longitude\"" >> "$installation_directory/config.me"

# Add the installation directory to the PATH
echo "export PATH=\$PATH:$installation_directory" >> ~/.bashrc
source ~/.bashrc

# Final messages
echo "Installation completed."
echo "Please confirm your configuration in $installation_directory/config.me."
echo "For additional guidance, refer to the usage guide available as remarks in the config.me file."
echo "To launch the application, navigate to the installation directory and run start.sh:"
echo "cd $installation_directory && ./start.sh"
