import os
import csv
import subprocess
import re
import requests
from bs4 import BeautifulSoup

def read_config():
    config = {}
    with open(os.path.join(os.path.dirname(__file__), '..', 'config.me'), 'r') as f:
        for line in f:
            if "=" in line:
                key, value = line.strip().split("=", 1)
                config[key] = value.strip('"')
    return config

def check_install_required_packages():
    try:
        import bs4
    except ImportError:
        subprocess.run(['pip', 'install', 'beautifulsoup4'], check=True)

def reformat_date(d):
    return f"{d[6:]}/{d[4:6]}/{d[:4]}"

def extract_url_content(html_content):
    soup = BeautifulSoup(html_content, 'html.parser')
    url_meta_tag = soup.find('meta', property='og:url')
    if url_meta_tag:
        return url_meta_tag['content']
    else:
        return ''

def extract_data(h, f, rep_fac, icao_to_iata_map):
    s = BeautifulSoup(h, 'html.parser')
    data = []
    p = f.split('-')
    flight_code, original_date = p[1].strip(), p[2].strip()[:-5] if len(p) >= 3 else ("", "")
    date = reformat_date(original_date)

    url_meta_tag = s.find('meta', property='og:url')
    dep, arr, url_content = "", "", ""
    if url_meta_tag:
        url_content = url_meta_tag['content']
        airports_match = re.search(r'\/([A-Z]+)\/([A-Z]+)\/tracklog', url_content)
        if airports_match:
            dep, arr = airports_match.groups()
            dep = icao_to_iata_map.get(dep, dep)
            arr = icao_to_iata_map.get(arr, arr)

    shortened_url = shorten_url(url_content) if url_content else ''

    for tr in s.select('tr'):
        reporting_facility = tr.select_one('td:nth-child(9)').text.strip() if tr.select_one('td:nth-child(9)') else ''
        if rep_fac in reporting_facility:
            try:
                row = {
                    'Date': date,
                    f'Time': tr.select_one('td:nth-child(1) span:nth-child(1)').text.strip(),
                    'Flight Code': flight_code,
                    'Dep': dep,
                    'Arr': arr,
                    'Latitude': tr.select_one('td:nth-child(2) span:nth-child(1)').text.strip(),
                    'Longitude': tr.select_one('td:nth-child(3) span:nth-child(1)').text.strip(),
                    'Course': tr.select_one('td:nth-child(4) span').text.strip(),
                    'kts': tr.select_one('td:nth-child(5)').text.strip(),
                    'km/h': tr.select_one('td:nth-child(6)').text.strip(),
                    'Alt(m)': tr.select_one('td:nth-child(7) span:nth-child(1)').text.strip(),
                    'Vert rate': tr.select_one('td:nth-child(8) span').text.strip(),
                    'Reporting Facility': reporting_facility,
                    'URL': shortened_url
                }
                data.append(row)
            except Exception as e:
                pass
    return data

def main():
    config = read_config()
    if config is None:
        return
    check_install_required_packages()

    inst_dir = config.get('installation_directory', '')
    rep_fac = config.get('reporting_facility', '')
    temp_dir = os.path.join(inst_dir, 'temp')

    icao_to_iata_map = {}
    icao2iata_path = os.path.join(inst_dir, 'backend', 'airport-library', 'icao2iata.csv')

    try:
        with open(icao2iata_path, 'r') as csvfile:
            reader = csv.reader(csvfile)
            next(reader)
            for row in reader:
                icao, iata = row
                icao_to_iata_map[icao] = iata
    except Exception as e:
        pass

    for f in os.listdir(temp_dir):
        if f.endswith('.html'):
            with open(os.path.join(temp_dir, f), 'r', encoding='utf-8') as file:
                h = file.read()
            d = extract_data(h, f, rep_fac, icao_to_iata_map)
            if not d:
                continue
            csv_filename = f.replace('.html', '.csv')
            try:
                with open(os.path.join(temp_dir, csv_filename), 'w', newline='') as csvfile:
                    fieldnames = ['Date', 'Time', 'Flight Code', 'Dep', 'Arr', 'Latitude', 'Longitude', 'Course', 'kts', 'km/h', 'Alt(m)', 'Vert rate', 'Reporting Facility', 'URL']
                    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                    writer.writeheader()
                    for row in d:
                        writer.writerow(row)
            except Exception as e:
                pass

def shorten_url(url):
    try:
        response = requests.post("https://is.gd/create.php", data={"format": "simple", "url": url})
        if response.status_code == 200:
            return response.text.strip()
    except Exception as e:
        print(f"An error occurred while shortening the URL: {e}")
    return url

if __name__ == "__main__":
    main()
