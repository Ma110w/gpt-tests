#!/bin/bash

# === CONFIG ===
FTP_HOST="ftp.maps.canada.ca"
FTP_PATH="/pub/nrcan_rncan/elevation/cdsm_mnsc/"
OUTPUT_DIR="./ftp_logs"
GIT_AUTHOR_NAME="ChatGPT-Bot"
GIT_AUTHOR_EMAIL="bot@example.com"

# === SETUP ===
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR" || exit 1

# === TRY TO FETCH FILE LIST ===
DATA=$(lftp -e "cls -1 $FTP_PATH; bye" "$FTP_HOST" 2>&1)
STATUS=$?

if [ $STATUS -eq 0 ]; then
    # Success: hash the sorted file list
    HASH=$(echo "$DATA" | sort | sha256sum | cut -c1-8)
    FILENAME="TRUE_${HASH}.txt"
    echo -e "{\n  \"status\": \"success\",\n  \"files\": [\n$(echo "$DATA" | sed 's/^/    "/;s/$/",/' | sed '$ s/,$//')\n  ]\n}" > "$FILENAME"
else
    # Failure: use hour_minute as hash
    TIME_HASH=$(date +"%H_%M")
    FILENAME="FALSE_${TIME_HASH}.txt"
    echo -e "{\n  \"status\": \"fail\",\n  \"error\": \"$(echo "$DATA" | head -n 1 | sed 's/"/\\"/g')\"\n}" > "$FILENAME"
fi

# === COMMIT TO GIT ===
cd .. || exit 1
git add "$OUTPUT_DIR/$FILENAME"
git -c user.name="$GIT_AUTHOR_NAME" -c user.email="$GIT_AUTHOR_EMAIL" commit -m "Auto log: $FILENAME"
git push
