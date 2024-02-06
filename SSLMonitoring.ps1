# Aviso: A variável $CRED está sendo utilizada para armazenar as credenciais.
# Certifique-se de que a credencial exista no cofre de credenciais do Windows.


# Data do Certificado
function Get-SSLCertificateExpiryDate {
    param (
        [string]$hostname,
        [int]$port = 443
    )

 
 # CONEXÃO TCTP
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($hostname, $port)
        $sslStream = [System.Net.Security.SslStream]::new($tcpClient.GetStream(), $false, { $true })
        $sslStream.AuthenticateAsClient($hostname)
        $cert = $sslStream.RemoteCertificate
        $expiry_date = $cert.GetExpirationDateString()
        $sslStream.Dispose()
        $tcpClient.Close()

        return [datetime]::Parse($expiry_date)
    } catch {
        throw "Erro ao verificar o certificado SSL de $hostname : $_"
    }
}

 

# DISPARANDO E-MAILS PELO GOOGLE
function Send-Email {
    param (
        [string]$subject,
        [string]$message
    )

 

    $sender_email = "XXXXXX@gmail.com"
    $cred = Get-StoredCredential -Target 'GMAIL'
    $senha = $($cred.GetNetworkCredential().Password);
    $receiver_email = @("XXXXXX@XXXXXX.com.br")
    $smtp_server = "smtp.gmail.com"
    $smtp_port = 587
    $msg = [System.Net.Mail.MailMessage]::new()
    $msg.From = $sender_email
    $msg.To.Add($receiver_email)
    $msg.Subject = $subject
    $msg.Body = $message
    $smtp = [System.Net.Mail.SmtpClient]::new($smtp_server, $smtp_port)
    $smtp.EnableSsl = $true
    $smtp.Credentials = [System.Net.NetworkCredential]::new($sender_email, $senha)


    try {
        # DISPARO
        $smtp.Send($msg)
        $smtp.Dispose()
        Write-Host "E-mail enviado com sucesso!"
    } catch {
        Write-Host "Erro ao enviar o e-mail: $_"
    }
}

 

try {
    # SUBSTITUA AQUI OS HOSTS QUE DEVEM TER A DATA DOS CERTIFICADOS VALIDADAS
    $websites = "XXXXXX.com.br", "XXXXX.com.br:9092"

    # Não sei o que isso faz KKKKKKKKKKKKK
    $results = @()

 

    foreach ($website in $websites) {
        try {
            if ($website -like "*:*") {
                $siteParts = $website -split ":"
                $site = $siteParts[0]
                $port = [int]$siteParts[1]
            } else {
                $site = $website
                $port = 443 
            }


            $expiry_date = Get-SSLCertificateExpiryDate $site $port
            $current_date = Get-Date


            if ($expiry_date -gt $current_date) {
                $days_remaining = ($expiry_date - $current_date).Days
                if ($days_remaining -le 360) {
                    $results += "ALERTA: O certificado SSL de $site expira em $days_remaining dias, em $expiry_date."
                }
            } else {
                $results += "O certificado SSL de $site já expirou em $expiry_date."
            }
        } catch {
            Write-Host $_
        }
    }


    if ($results.Count -gt 0) {
        $alert_message = $results -join "`r`n"
        Send-Email "Aviso de Certificados Expirando" $alert_message
    }
} catch {
    Write-Host "Erro ao ler o arquivo de sites: $_"
}
