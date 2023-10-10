# Script PowerShell for ERMx Windows Setup
# Version 20231010

# Use o comando "Set-ExecutionPolicy RemoteSigned" para permitir a execução de scripts não assinados

# Control variables
$VPNNetwork = "172.24.0.0/21"

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
Write-Host ("~" * $colunas) -ForegroundColor Green
Write-Host "`n Este script deve ser executado como administrador"
Write-Host " Este script deve ser executado com a OpenVPN ativa e conectada.`n"
Write-Host ("~" * $colunas) -ForegroundColor Green
Write-Host " `nSugere-se ainda que:"
Write-Host "    - Remova a computador do dominio e mantenha apenas duas contas locais"
Write-Host "           (uma para administrar, outra para executar aplicativos)"
Write-Host "    - Ative o auto-boot com ativação da energia AC na BIOS"
Write-Host "    - Configure o auto-login no Windows"
Write-Host "    - Configure e teste a OpenVPN com a chave da ERMx.`n"
Write-Host " `nAo terminar o script, deve-se reiniciar o computador.`n"
Write-Host "Deseja continuar? (S/N)"
$confirm = Read-Host
if ($confirm -ne "S") {
    exit
}
Write-Host ("~" * $colunas) -ForegroundColor Green
Write-Host "`n"

# Get the network interface for the specified IP range used by OpenVPN
$Interface = Get-NetRoute | Where-Object {$_.DestinationPrefix -eq "$VPNNetwork"}

# Check if the interface was found and add the routes
if ($Interface -eq $null) {
    Write-Host "Sem interface para OpenVPN. Verifique a conexão VPN e tente novamente."
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
New-NetFirewallRule -DisplayName "Área de Trabalho Remota - Modo de Usuário (TCP-Entrada-9081)" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9081 -Profile Any -Program Any -Service Any -Enabled True
New-NetFirewallRule -DisplayName "Área de Trabalho Remota - Modo de Usuário (UDP-Entrada-9081)" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 9081 -Profile Any -Program Any -Service Any -Enabled True

Write-Host "Ativado serviço de Área de Trabalho Remota na porta 9081."

# Activate firewall rule to enable ping response
Get-NetFirewallRule -name "CoreNet-Diag-ICMP4-EchoRequest-In-NoScope" | Set-NetFirewallRule -Enabled True -Profile Any -RemoteAddress "10.0.0.0/8","192.168.0.0/16","172.16.0.0/12"

# Change network interface for network 172.24.0.0 as "rede privada"
Set-NetConnectionProfile -InterfaceAlias $Interface.InterfaceAlias -NetworkCategory Private

Write-Host "OpenVPN configurada como rede privada e ativada regra para resposta a ping."

Write-Host ("~" * $colunas) -ForegroundColor Green
Write-Host "Para acesso remoto via RDP utilize agora a porta 9081." 
Write-Host ("~" * $colunas) -ForegroundColor Green
Write-Host "O computador será reiniciado em 5 segundos. Use Ctrl+C para interromper" -ForegroundColor Red

# Print countdow to restart for 10 seconds
for ($i = 10; $i -gt 0; $i--) {
    for ($i = 10; $i -gt 0; $i--) {
        Write-Host -NoNewLine "`rReiniciando em $i segundos..."
        Start-Sleep -Seconds 1
    }
    Start-Sleep -Seconds 1
}
# Restart computer
Restart-Computer -Force