# Using fuff pipes on a winzoz box (oh my...)
Since I'm a big Winzoz f(a)n, based on the following resource: http://ffuf.me/cd/pipes<br>
we can use the following Powershel commands to accomplish the same tasks

##  Test parameter for an [IDOR](https://portswigger.net/web-security/access-control/idor) vulnerability and try some integers against it.

    PS C:\Users\XXXXX\ffuf> 1..1000 | % { write "$_" } | .\ffuf.exe -w - -u http://ffuf.me/cd/pipes/user?id=FUZZ
    
## Finding the md5 hashed ID

    PS C:\Users\XXXXX\ffuf> 900..1000 | % { ([System.BitConverter]::ToString((New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider).ComputeHash((New-Object -TypeName System.Text.UTF8Encoding).GetBytes($_)))).Replace("-","").ToLower() } | .\ffuf.exe -w - -u http://ffuf.me/cd/pipes/user3?id=FUZZ
    
## Finding the base64 encoded ID

    PS C:\Users\XXXXX\ffuf\cs tools> 800..900 | % { [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($_.ToString())) } | .\ffuf -w - -u http://ffuf.me/cd/pipes/user2?id=FUZZ
