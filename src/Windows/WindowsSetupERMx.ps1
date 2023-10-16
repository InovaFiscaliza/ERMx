# Script PowerShell for ERMx Windows Setup


# Use o comando "Set-ExecutionPolicy RemoteSigned" para permitir a execução de scripts não assinados

# Control variables
$version = "1.0" # script version from 16/10/2023
$VPNNetwork = "172.24.0.0/21"

$user = "Fiscal"
$password = "ermx"

$Routes = @(
    @{ DestinationNetwork = "192.168.64.0/18"; GatewayIP = "172.24.0.1" },
    @{ DestinationNetwork = "192.168.128.0/17"; GatewayIP = "172.24.0.1" },
    @{ DestinationNetwork = "10.0.0.0/8"; GatewayIP = "172.24.0.1" }
)

# Print script header message
$colunas = $Host.UI.RawUI.BufferSize.Width
Write-Host "`n"
Write-Host ("~" * $colunas) -ForegroundColor Green
Write-Host "Script para configurar computadores Windows para uso em rede como ERMx" -ForegroundColor Green
Write-Host "Versão: $version" -ForegroundColor Green
Write-Host ("~" * $colunas) -ForegroundColor Green
Write-Host "`nPre-requisitos:"
Write-Host "    - Certifique-se que foi habilitado o auto-boot com ativacao da energia AC na BIOS"
Write-Host "    - Certifique-se que este computador tenha sido formatado e encontra-se com a instalacao limpa do Windows (e atualizado ate a versao 22H2 ou superior)"
Write-Host "    - Certifique-se que esta maquina tenha sido inicializada com perfil administrador local"
Write-Host "    - Certifique-se que o OpenVPN GUI tenha sido instalado, configurado e conectado."
Write-Host "    - Certifique-se que a rede local ethernet tenha sido configurada com IP estatico na faixa 192.168.0.0/24`n"
Write-Host ("~" * $colunas) -ForegroundColor Green
Write-Host "`nAo terminar o script, o computador sera reiniciado.`n"
Write-Host "Deseja continuar? (S/N)"
$confirm = Read-Host
if ($confirm -ne "S") {
    exit
}
Write-Host ("~" * $colunas) -ForegroundColor Green
Write-Host "`n"

# create a restore point
Write-Host "`nCriando um ponto de restauracao antes da execucao das configuracoes."
Enable-ComputerRestore "C:\"
Checkpoint-Computer -Description "Ponto de restauração criado pelo script de configuração do ERMx, pré-execução"
Write-Host "Ponto de restauracao criado pelo script de configuração do ERMx, pre-execucao.`n"

# configure openvpn client to start as a service
Set-Service -Name "OpenVPNService" -StartupType Automatic
Write-Host "`nOpenVPN habilitado como serviço, com inicialização automática com o Windows.`n "

# Create a user account with the login "Fiscal" and password "ermx"
New-LocalUser -Name $user -Password (ConvertTo-SecureString $password -AsPlainText -Force) -FullName "Fiscalização Anatel" -Description "Usuário para uso em fiscalização da Anatel" -NoPasswordExpiration
Write-Host "`nCriado usuário $user no Windows para uso em fiscalização (Senha: $password).`n"

# disable automatic windows update
stop-Service wuauserv
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -value 1
Write-Host "`nDesabilitadas as atualizacoes automaticas do Windows Update.`n"

# Enable auto logon for default user and password
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -value "Fiscal"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -value "ermx"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -value 1
Write-Host "`nHabilitado o logon automático do usuário criado.`n"

# Get the network interface for the specified IP range used by OpenVPN
$Interface = Get-NetRoute | Where-Object {$_.DestinationPrefix -eq "$VPNNetwork"}

# Check if the interface was found and add the routes
if ($Interface -eq $null) {
    Write-Host "`nSem interface para OpenVPN. Verifique a conexao VPN e tente novamente.`n"
} else {
    foreach ($RouteInfo in $Routes) {
        $DestinationNetwork = $RouteInfo.DestinationNetwork
        $GatewayIP = $RouteInfo.GatewayIP

        # Add a route using the interface ID and gateway IP
        New-NetRoute -DestinationPrefix "$DestinationNetwork" -InterfaceIndex $Interface.InterfaceIndex -NextHop $GatewayIP -RouteMetric 1

        Write-Host "Adicionada rota $DestinationNetwork via $GatewayIP na interface $($Interface.InterfaceAlias) (ID: $($Interface.InterfaceIndex))."
    }
}

# Configure RDP port to 9081
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name PortNumber -value 9081

# Activate RDP service
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -value 0

# Create new rule for RDP port 9081
New-NetFirewallRule -DisplayName "Area de Trabalho Remota - Modo de Usuário (TCP-Entrada-9081)" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9081 -Profile Any -Program Any -Service Any -Enabled True
New-NetFirewallRule -DisplayName "Area de Trabalho Remota - Modo de Usuário (UDP-Entrada-9081)" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 9081 -Profile Any -Program Any -Service Any -Enabled True

Write-Host "`nAtivado servico de Area de Trabalho Remota na porta 9081.`n"

# Activate firewall rule to enable ping response
Get-NetFirewallRule -name "CoreNet-Diag-ICMP4-EchoRequest-In-NoScope" | Set-NetFirewallRule -Enabled True -Profile Any -RemoteAddress "10.0.0.0/8","192.168.0.0/16","172.16.0.0/12"

# Change network interface for network 172.24.0.0 as "rede privada"
Set-NetConnectionProfile -InterfaceAlias $Interface.InterfaceAlias -NetworkCategory Private

Write-Host "`nOpenVPN configurada como rede privada e ativada regra no firewall para resposta a ping.`n"

# create a restore point
Write-Host "`nCriando um ponto de restauracao apos a execucao das configuracoes."
Checkpoint-Computer -Description "Ponto de restauração criado pelo script de configuração do ERMx, pós-execução"
Write-Host "Ponto de restauracao criado pelo script de configuracao do ERMx, pos-execucao.`n"

Write-Host ("~" * $colunas) -ForegroundColor Green
Write-Host "Para acesso remoto via RDP utilize agora a porta 9081." 
Write-Host ("~" * $colunas) -ForegroundColor Green
Write-Host "`nO computador será reiniciado em 10 segundos. Use Ctrl+C para interromper a reinicialização`n" -ForegroundColor Red

# Print countdow to restart for 10 seconds
for ($i = 10; $i -gt 0; $i--) {
    for ($i = 10; $i -gt 0; $i--) {
        Write-Host "Reiniciando em $i segundos..." -ForegroundColor Red
        Start-Sleep -Seconds 1
    }
    Start-Sleep -Seconds 1
}
# Restart computer
Restart-Computer -Force