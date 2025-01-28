#!/bin/sh

# Path to the GoAccess configuration file
CONFIG_FILE="/config/goaccess.conf"

if [ ! -f ${CONFIG_FILE} ] ; then
  echo "ERROR: Config file missing at /config/goaccess.conf"
  exit 1
fi

# Extract all log-file paths
LOG_FILES=$(grep '^log-file' "$CONFIG_FILE" | awk '{print $2}')

# Build the zcat command for all files
ZCAT_CMD=""
files_found="0"

for FILE in $LOG_FILES; do
  if [ -f "$FILE" ] ; then
    echo "INFO: Adding log file: $FILE"

    # Check if the file is a .gz file
    if [ "${FILE##*.}" = "gz" ]; then
      files_found="1"
      # Append zcat for .gz files
      ZCAT_CMD="$ZCAT_CMD $FILE"
    fi

    # Check for additional compressed files (${FILE}.*.gz)
    echo "INFO: Checking for compressed files: ${FILE}.*.gz"
    for GZ_FILE in ${FILE}.*.gz; do
      if [ -f "$GZ_FILE" ]; then
        files_found="1"
        echo "INFO: Adding compressed log files: ${FILE}.*.gz"
        ZCAT_CMD="$ZCAT_CMD ${FILE}.*.gz"
        break
      fi
    done

  else
    echo "WARN: Log file not found: $FILE"
  fi
done

if [ "${files_found}" = "1" ] ; then
  ZCAT_CMD="zcat$ZCAT_CMD"
fi

# Remove the trailing pipe and build the full command
FULL_CMD="$ZCAT_CMD | goaccess - --no-global-config --config-file=$CONFIG_FILE"

echo "Full command: ${FULL_CMD}"

# ready to go 
/sbin/tini -s -- nginx -c /opt/nginx.conf

# Run the command with /sbin/tini
exec /sbin/tini -s -- sh -c "$FULL_CMD"