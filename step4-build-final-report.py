import os
import csv
import re

def main():
    config = {}
    parent_dir = os.path.dirname(os.path.abspath(__file__))
    config_file = os.path.join(parent_dir, '../config.me')
    if os.path.exists(config_file):
        with open(config_file, 'r') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                key, value = line.split('=', 1)
                config[key] = value.strip('"')
        installation_directory = config.get('installation_directory')
    else:
        print("Error: config.me file not found.")
        return

    if installation_directory is None:
        print("Error: Installation directory not specified in config.me.")
        return

    input_dir, output_dir = os.path.join(installation_directory, 'temp'), os.path.join(installation_directory, 'report')
    os.makedirs(output_dir, exist_ok=True)
    output_csv = os.path.join(output_dir, 'positions-used-by-flightaware.csv')
    all_rows = []
    if os.path.exists(output_csv):
        with open(output_csv, 'r') as f:
            all_rows.extend(csv.DictReader(f))
    tz = None

    for filename in os.listdir(input_dir):
        if filename.endswith('.csv') and 'tracklog_links' not in filename:
            date_str = filename.split(" - ")[-1].replace('.csv', '')
            formatted_date = f"{date_str[6:8]}/{date_str[4:6]}/{date_str[0:4]}"
            with open(os.path.join(input_dir, filename), 'r') as f:
                csv_reader = csv.DictReader(f)
                if tz is None and csv_reader.fieldnames:
                    time_field = next((field for field in csv_reader.fieldnames if "Time" in field), None)
                    if time_field:
                        match = re.match(r'Time \((.*?)\)', time_field)
                        if match:
                            tz = match.group(1)
                for row in csv_reader:
                    row['Date'] = formatted_date
                    all_rows.append(row) if row not in all_rows else None

    if tz is None:
        print("Error: Time zone ('tz') could not be determined from the tracklog CSVs.")
        return

    if all_rows:
        time_column = [col for col in all_rows[0].keys() if col.startswith("Time")][0] if any(col.startswith("Time") for col in all_rows[0].keys()) else None
        if time_column:
            all_rows.sort(key=lambda x: (x['Date'], x[time_column]))
            with open(output_csv, 'w', newline='') as f:
                fieldnames = all_rows[0].keys()
                csv_writer = csv.DictWriter(f, fieldnames=fieldnames)
                csv_writer.writeheader()
                for row in all_rows:
                    csv_writer.writerow(row)

            print("{:<15} {:<18} {:<15} {:<8} {:<8} {:<12} {:<12} {:<10} {:<10} {:<10} {:<10} {:<10} {:<25} {:<40}".format(
                "Date", f"Time ({tz})", "Flight Code", "Dep", "Arr", "Latitude", "Longitude", "Course",
                "kts", "km/h", "Alt(m)", "Vert rate", "Reporting Facility", "URL"
            ))
            print("-" * 196)  # Add a line under the header row

            for row in all_rows:
                print("{:<15} {:<18} {:<15} {:<8} {:<8} {:<12} {:<12} {:<10} {:<10} {:<10} {:<10} {:<10} {:<25} {:<40}".format(
                    row["Date"], row.get(f"Time ({tz})", ""), row["Flight Code"], row["Dep"], row["Arr"], row["Latitude"],
                    row["Longitude"], row["Course"], row["kts"], row["km/h"], row["Alt(m)"], row["Vert rate"],
                    row["Reporting Facility"], row.get("URL", "")
                ))

if __name__ == "__main__":
    main()
