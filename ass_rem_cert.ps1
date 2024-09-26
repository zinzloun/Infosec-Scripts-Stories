##### CONFIG #####
$host_ = "localhost"
$port = 443

# Set TLS version, on Win11 you can use [SystemDefault;Ssl3;Tls;Tls11;Tls12;Tls13]
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls13
$TCPClient = New-Object -TypeName System.Net.Sockets.TCPClient
$TcpSocket = New-Object Net.Sockets.TcpClient($host_,$port)
$tcpstream = $TcpSocket.GetStream()
# if the certificate is NOT self-signed you can comment the following line
$Callback = {param($sender,$cert,$chain,$errors) return $true}
$SSLStream = New-Object -TypeName System.Net.Security.SSLStream -ArgumentList @($tcpstream, $True, $Callback)
$SSLStream.AuthenticateAsClient($host_)
$Certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($SSLStream.RemoteCertificate)
$SSLStream.Dispose()
$TCPClient.Dispose()
$Certificate
