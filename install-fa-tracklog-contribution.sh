#!/bin/bash

# Function to download a file from GitHub
download_file () {
  wget -O "$2" "$1" || { echo "Error downloading $1"; exit 1; }
}

# Update and upgrade the system
sudo apt update
sudo apt upgrade -y

# Install required utilities and packages if not already installed
# Check for wget and install if missing
if ! command -v wget &> /dev/null; then
    echo "wget is not installed. Installing..."
    sudo apt install -y wget
fi

# Check for unzip and install if missing
if ! command -v unzip &> /dev/null; then
    echo "unzip is not installed. Installing..."
    sudo apt install -y unzip
fi

# Check for ChromeDriver and install if missing
if ! command -v chromedriver &> /dev/null; then
    echo "Installing ChromeDriver..."
    wget https://github.com/electron/electron/releases/download/v3.0.0/chromedriver-v3.0.0-linux-armv7l.zip
    unzip chromedriver-v3.0.0-linux-armv7l.zip
    sudo mv chromedriver /usr/local/bin/
    rm chromedriver-v3.0.0-linux-armv7l.zip
    if command -v chromedriver &> /dev/null; then
        echo "ChromeDriver installed."
    else
        echo "ChromeDriver installation failed."
        exit 1
    fi
fi

# Install required Python packages
sudo apt install -y python3-selenium python3-bs4

# Get the current directory
current_directory=$(pwd)

# Default installation directory (full path)
default_installation_directory="$current_directory/fa-tracklog-contribution"

# Ask user for installation directory (full path)
read -rp "Please specify the installation directory, or just press ENTER for default [$default_installation_directory]: " installation_directory
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
echo "Installation completed. Please navigate to the installation directory by running:"
echo "cd $installation_directory"
