# Configurações do e-mail

$smtpServer = "smtp.gmail.com" # Endereço do servidor SMTP
$smtpPort = 587 # Porta do servidor SMTP
$smtpUsername = "" # Nome de usuário do e-mail remetente
$smtpPassword = "" # Senha do e-mail remetente
$fromEmail = "" # Endereço de e-mail remetente
$toEmail = "" # Endereço de e-mail do destinatário
$subjectUpdateFalse = "Não ha Updates no WSUS" # Assunto do e-mail
$subjectUpdateTrue = "Novos updates no WSUS"
$bodyUpdateTrue = "Ha updates para aprovacao no Wsus $global:lista"
$bodyUpdateFalse = "Nao ha updates aguardando para aprovação no WSUS
MUITO BEM!"


##FUNÇÃO QUE VERIFICA OS UPDATES DISPONÍVEIS NO WSUS

function List{

       $updates = Get-WsusUpdate -Classification All -Approval Unapproved -Status Needed

    if ($updates.Count -eq 0) {
        Write-Host "Não há atualizações necessárias" -ForegroundColor Green
        $global:email = $false
    } else {
        Write-Host "Há atualizações necessárias, verifique mais detalhes no painel do WSUS:" -ForegroundColor Green
        $global:lista = @()  # Inicializar a lista vazia
        foreach ($update in $updates) {
            $global:lista += "- $($update.Update.Title)"
            $global:email = $true
        }
    }
}

List
$global:lista

##FUNÇÃO QUE DISPARA O EMAIL

function DisparoEmail {

    if (-not $email) {
        # Cria objeto com as configurações do e-mail
        $mailParams = @{
            SmtpServer = $smtpServer
            Port = $smtpPort
            UseSsl = $true
            Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $smtpUsername, (ConvertTo-SecureString -String $smtpPassword -AsPlainText -Force)
            From = $fromEmail
            To = $toEmail
            Subject = $subjectUpdateFalse
            Body = $bodyUpdateFalse
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
            Subject = $subjectUpdateTrue
            Body = "Ha atualizaçoes criticas aguardando aprovacao no WSUS:`n$($global:lista -join "`n")"
        }
    
        # Envia o e-mail
        Send-MailMessage @mailParams
    
        Write-Host "E-mail de sucesso enviado para $toEmail."
    }
}

DisparoEmail
