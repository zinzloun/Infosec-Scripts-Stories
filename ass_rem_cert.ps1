##### CONFIG #####
$host = "127.0.0.1"
$port = 443

# Set TLS version
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls13
$TCPClient = New-Object -TypeName System.Net.Sockets.TCPClient
$TcpSocket = New-Object Net.Sockets.TcpClient($host,$ip)
$tcpstream = $TcpSocket.GetStream()
# if the certificate is NOT self-signed you can comment the following line
$Callback = {param($sender,$cert,$chain,$errors) return $true}
$SSLStream = New-Object -TypeName System.Net.Security.SSLStream -ArgumentList @($tcpstream, $True, $Callback)
$SSLStream.AuthenticateAsClient($IP)
$Certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($SSLStream.RemoteCertificate)
$SSLStream.Dispose()
$TCPClient.Dispose()
$Certificate
