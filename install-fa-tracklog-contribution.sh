#!/bin/bash

# Update and upgrade all packages
sudo apt update
sudo apt upgrade -y

# Install required packages if not installed
sudo apt install -y python3-selenium python3-bs4 unzip chromium-browser

# Install or update ChromeDriver
if ! command -v chromedriver &> /dev/null; then
    echo "Installing ChromeDriver..."
    wget https://chromedriver.storage.googleapis.com/2.41/chromedriver_linux64.zip
    unzip chromedriver_linux64.zip
    sudo mv chromedriver /usr/local/bin/
    sudo chmod +x /usr/local/bin/chromedriver
    echo "ChromeDriver installed."
else
    echo "ChromeDriver is already installed."
fi

# Install or update Chromium Browser
echo "Installing or updating Chromium Browser..."
sudo apt install --only-upgrade chromium-browser -y
echo "Chromium Browser installed or updated."

# Define the installation directory
install_dir="$HOME/fa-tracklog-contribution"

# Create required directories
mkdir -p "$install_dir" "$install_dir/backend/airport-library"

# Download essential files
github_repo="https://raw.githubusercontent.com/yanniedog/flightaware-contribution/main"
files=("start.sh" "config.me" "icao2iata.csv" "step1-fa-stats-page.py" "step2-download-tracklog-htmls.py" "step3-scrape-local-htmls.py" "step4-build-final-report.py" "step5-erase-temp-files.py")

for file in "${files[@]}"; do
    wget -O "$install_dir/$file" "$github_repo/$file" || { echo "Error downloading $file"; exit 1; }
done

# Make start.sh executable
chmod +x "$install_dir/start.sh"

# Update config.me file with user-specific info
read -rp "Please enter your FlightAware username: " username
read -rp "Please enter the term that will identify your ADS-B receiver: " reporting_facility

sed -i "s|username=\".*\"|username=\"$username\"|g" "$install_dir/config.me"
sed -i "s|reporting_facility=\".*\"|reporting_facility=\"$reporting_facility\"|g" "$install_dir/config.me"
sed -i "s|installation_directory=\".*\"|installation_directory=\"$install_dir\"|g" "$install_dir/config.me"

echo "Installation completed."
echo "Please confirm your configuration in $install_dir/config.me."
echo "For additional guidance, refer to the usage guide available as remarks in the config.me file."
echo "To launch the application, navigate to the installation directory and run start.sh:"
echo "cd $install_dir && ./start.sh"
