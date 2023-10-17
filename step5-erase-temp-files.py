# Script Name: step5-erase-temp-files.py

import os
import time

def countdown_timer(seconds):
    for i in range(seconds, 0, -1):
        print(f"Waiting for {i} seconds before erasing temporary files...", end='\r')
        time.sleep(1)

def main():
    config = {}
    parent_dir = os.path.dirname(os.path.abspath(__file__))
    config_file = os.path.join(parent_dir, '../config.me')  # Assuming 'config.me' is in the parent directory
    if os.path.exists(config_file):
        with open(config_file, 'r') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):  # Skip empty lines and comments
                    continue
                key, value = line.strip().split('=', 1)
                config[key] = value.strip('"')
        cleanup_delay = int(config.get('cleanup_delay', 60))
        installation_directory = config.get('installation_directory')
    else:
        print("Error: config.me file not found or invalid entry. Cleanup canceled.")
        return
    if cleanup_delay is not None and installation_directory:
        temp_directory = os.path.join(installation_directory, 'temp')
        if cleanup_delay > 0:
            countdown_timer(cleanup_delay)
            print("\nCleaning up temporary files...")
        for filename in os.listdir(temp_directory):
            filepath = os.path.join(temp_directory, filename)
            print(f"Deleting {filename}...")
            os.remove(filepath)
    else:
        print("Error: Cleanup delay or installation directory not specified in config.me. Cleanup canceled.")

if __name__ == "__main__":
    main()
