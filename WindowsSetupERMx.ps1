# Script PowerShell de Configura��o do Windows para uso do ERMx
#

# imprime mensagens de alerta com condi��es necess�rias para a execu��o do script
$colunas = $Host.UI.RawUI.BufferSize.Width
Write-Host "`n"
Write-Host ("_" * $colunas) -ForegroundColor Green
Write-Host "Este script deve ser executado com privil�gios de administrador."
Write-Host "Este script deve ser executado com a conex�o OpenVPN ativa.`n"
Write-Host "Sugere-se ainda que:"
Write-Host "    - Remova a m�quina do dom�nio da Anatel e criu duas contas locais"
Write-Host "           (uma para administra��o, outra para execu��o do appColeta)"
Write-Host "    - Ative o boot autom�tico na energia AC na BIOS"
Write-Host "    - Configure o login autom�tico no Windows"
Write-Host "    - Configure e teste a conex�o OpenVPN com a chave da esta��o.`n"
Write-Host "Deseja continuar? (S/N)"
$confirm = Read-Host
if ($confirm -ne "S") {
    exit
}
Write-Host ("_" * $colunas) -ForegroundColor Green
Write-Host "`n"

# Obt�m o IP da OpenVPN da interface onde o IP come�a com "172.24." e armazena na vari�vel $openVpnIp
$openVpnIp = (Get-NetIPAddress | Where-Object {$_.IPAddress -like "172.24.*"}).IPAddress

# Se n�o encontrar a interface, exibe mensagem de erro e sai
if ($openVpnIp -eq $null) {
    Write-Host "N�o foi poss�vel encontrar a interface TUN do OpenVPN. Verifique a conex�o VPN e tente novamente."
    exit
}
exit
<#
# Configura o IP da interface como gateway para a rede da Anatel
route -p add 192.168.64.0 MASK 255.255.192.0 $openVpnIp
route -p add 192.168.128.0 MASK 255.255.128.0 $openVpnIp
route -p add 10.0.0.0 MASK 255.0.0.0 $openVpnIp

# Configura o RDP par porta 9081
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name PortNumber -value 9081

# Ativa o Remote Desktop
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -value 0

# Ativa a regra para permitir resposta ao ping ativando todas as regras do grupo "Diagn�stico do Sistema de Rede B�sico"
Get-NetFirewallRule -DisplayGroup "Diagn�stico do Sistema de Rede B�sico" | Set-NetFirewallRule -Enabled True

# Cria regra de firewall permitindo RDP para todas as redes na porta 9081
New-NetFirewallRule -DisplayName "�rea de Trabalho Remota - Modo de Usuário (TCP-Entrada-9081)" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9081 -Profile Any -Program Any -Service Any -Enabled True
New-NetFirewallRule -DisplayName "�rea de Trabalho Remota - Modo de Usuário (UDP-Entrada-9081)" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 9081 -Profile Any -Program Any -Service Any -Enabled True

# Reinicializa o computador
Restart-Computer -Force
#>