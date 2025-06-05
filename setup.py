import hashlib
import json
import datetime
import os
import subprocess
from ftplib import FTP

# === CONFIG ===
FTP_HOST = 'ftp.maps.canada.ca'
FTP_PATH = '/pub/nrcan_rncan/elevation/cdsm_mnsc/'
GIT_AUTHOR = "ChatGPT-Bot <bot@example.com>"
OUTPUT_DIR = "./ftp_logs"  # optional subdirectory for storing logs

# Ensure output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

def generate_hash(data):
    serialized = json.dumps(data, sort_keys=True).encode('utf-8')
    return hashlib.sha256(serialized).hexdigest()[:8]  # shorten for filename

def current_time_hash():
    now = datetime.datetime.now()
    return now.strftime('%H_%M')

try:
    ftp = FTP(FTP_HOST)
    ftp.login()
    ftp.cwd(FTP_PATH)

    files = []
    ftp.retrlines('LIST', files.append)
    ftp.quit()

    result_data = {
        "status": "success",
        "files": files
    }

    file_hash = generate_hash(result_data)
    filename = f"TRUE_{file_hash}.txt"

except Exception as e:
    result_data = {
        "status": "fail",
        "error": str(e)
    }

    file_hash = current_time_hash()
    filename = f"FALSE_{file_hash}.txt"

# === WRITE FILE ===
filepath = os.path.join(OUTPUT_DIR, filename)
with open(filepath, 'w', encoding='utf-8') as f:
    json.dump(result_data, f, indent=2)

# === COMMIT TO GIT ===
subprocess.run(['git', 'add', filepath])
subprocess.run(['git', '-c', f"user.name={GIT_AUTHOR.split()[0]}", '-c', f"user.email={GIT_AUTHOR.split()[1][1:-1]}", 'commit', '-m', f"Auto log: {filename}"])
subprocess.run(['git', 'push'])
