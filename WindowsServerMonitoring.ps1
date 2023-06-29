# PARAMETROS DE CONEXÃO E EMAIL

$smtpServer = "smtp.gmail.com" # Endereço do servidor SMTP
$smtpPort = 587 # Porta do servidor SMTP
$smtpUsername = "XXXXXXX@gmail.com" # Nome de usuário do e-mail remetente
$smtpPassword = "XXXXXXXXXXX" # Senha do e-mail remetente
$fromEmail = "XXXXXXXXXX" # Endereço de e-mail remetente
$toEmail = "XXXXXXXXXXX" # Endereço de e-mail do destinatário
$subject = "RELATORIO DE BACKUP DO WINDOWS SERVER" # Assunto do e-mail
$body = "Dados do relatorio de Backup" 


# FIM DOS PARÂMETROS DE CONEXÃO





# DEFINA OS SERVIDORES A SEREM INSPECIONADOS

$servers = "SRVVM", "SRVVMBKP" , "SRVVMSEC" , "SRVVMSECAD" , "ZEUS"

$results = @() # ARMAZENA OS RESULTADOS DE CADA FOREACH

$scriptBlock = {
    $backupSummary = Get-WBSummary
    $lastBackupResult = $backupSummary.LastBackupResult
    $lastBackupTime = $backupSummary.LastBackupTime

    $data = (Get-WBSummary | Select-Object -ExpandProperty LastBackupResultHR)  # COMANDO PARA PEGAR O DADO DO ULTIMO BACKUP / TRUE = 0

    Write-Host "Data do último backup do servidor: $lastBackupTime"

    if ($data -eq 0) {
        Write-Host -ForegroundColor Green "BACKUP BEM SUCEDIDO"
        $result = "BACKUP BEM SUCEDIDO"
    } else {
        Write-Host -ForegroundColor Red "BACKUP FALHOU"
        $result = "BACKUP FALHOU"
    }

    return $result
}

# RESULTADO DOS BKPS DE CADA SERVIDOR ESPECIFICADO

foreach ($server in $servers) {
    Write-Host "$server"
    $result = Invoke-Command -ComputerName $server -ScriptBlock $scriptBlock
    $results += "$server : $result"

    Write-Host "---------------------------------------"
}

# RESULTADO FINAL DOS BKPS
Write-Host "Resultados:"
foreach ($result in $results) {
    Write-Host $result
}

# ENVIO DO EMAIL
$lastResult = $results -join "`n" 

# PARAMETROS MASSA BIXO LEGAL

$mailParams = @{
    SmtpServer = $smtpServer
    Port = $smtpPort
    UseSsl = $true
    Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $smtpUsername, (ConvertTo-SecureString -String $smtpPassword -AsPlainText -Force)
    From = $fromEmail
    To = $toEmail
    Subject = $subject
    Body = $body + "`n`nResultados do ultimo backup:
    `n$lastResult"
}

try {
    Send-MailMessage @mailParams
    Write-Host -ForegroundColor Green "
    Email enviado com sucesso!
    "
} catch {
    Write-Host -ForegroundColor Red "
    Falha ao enviar o email: $($_.Exception.Message)"
}

