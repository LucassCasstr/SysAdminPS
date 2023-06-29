# Configurações do e-mail
$dataUltimoBackup = ($arquivosNovos | Sort-Object -Property LastWriteTime -Descending)[0].LastWriteTime
$smtpServer = "smtp.gmail.com" # Endereço do servidor SMTP
$smtpPort = 587 # Porta do servidor SMTP
$smtpUsername = "XXXXXXXX@gmail.com" # Nome de usuário do e-mail remetente
$smtpPassword = "XXXXXXXX" # Senha do e-mail remetente
$fromEmail = "XXXXXXXX@gmail.com" # Endereço de e-mail remetente
$toEmail = "XXXXXXXXXXXXXXXX" # Endereço de e-mail do destinatário
$subjectErro = "BACKUP FALHO" # Assunto do e-mail
$subjectSucesso = "BACKUP OK"
$bodyErro = "A PASTA XXXXXXXX ESTA A MAIS DE UM DIA SEM RECEBER NENHUM BACKUP
XXXXXXXXXXXXXXXXXXXXXXXX

DATA DO ULTIMO ARQUIVO: $dataUltimoBackup

"
$bodySucesso = "A PASTA XXXXXXXX ESTA RECEBENDO OS BACKUPS
DATA DO ULTIMO BACKUP: $dataUltimoBackup
"


$pasta = "XXXXXXXXXXXXXXXX"


$dataAtual = Get-Date

# Obtém a lista de arquivos na pasta que foram modificados nos últimos 1 dia
$arquivosNovos = Get-ChildItem -Path $pasta -File | Where-Object {
    $_.LastWriteTime -gt $dataAtual.AddDays(-1)
}

# Verifica se há arquivos novos
if ($arquivosNovos) {
    Write-Host "A pasta $pasta recebeu arquivos novos nos últimos 1 dia."
    $email = $true
} else {
    Write-Host "A pasta $pasta não recebeu arquivos novos nos últimos 1 dia."
    $email = $false
}

$email


if (-not $email) {
    # Cria objeto com as configurações do e-mail
    $mailParams = @{
        SmtpServer = $smtpServer
        Port = $smtpPort
        UseSsl = $true
        Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $smtpUsername, (ConvertTo-SecureString -String $smtpPassword -AsPlainText -Force)
        From = $fromEmail
        To = $toEmail
        Subject = $subjectErro
        Body = $bodyErro
    }
    
    # Envia o e-mail
    Send-MailMessage @mailParams
    
    Write-Host "E-mail de erro enviado para $toEmail."
} else {
        $mailParams = @{
        SmtpServer = $smtpServer
        Port = $smtpPort
        UseSsl = $true
        Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $smtpUsername, (ConvertTo-SecureString -String $smtpPassword -AsPlainText -Force)
        From = $fromEmail
        To = $toEmail
        Subject = $subjectSucesso
        Body = $bodySucesso
    }
    
    # Envia o e-mail
    Send-MailMessage @mailParams
    
    Write-Host "E-mail de sucesso enviado para $toEmail."
}


