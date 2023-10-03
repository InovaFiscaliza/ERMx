# Script PowerShell de Configuração do Windows para uso do ERMx

# imprime mensagens de alerta com condições necessárias para a execução do script
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

# Obtém o IP da OpenVPN da interface onde o IP começa com "172.24." e armazena na variável $openVpnIp
$openVpnIp = (Get-NetIPAddress | Where-Object {$_.IPAddress -like "172.24.*"}).IPAddress

# Se não encontrar a interface, exibe mensagem de erro e sai
if ($openVpnIp -eq $null) {
    Write-Host "Sem interface para OpenVPN. Verifique a conexão VPN e tente novamente."
    exit
}

# Configura o IP da interface como gateway para a rede da Anatel
route -p add 192.168.64.0 MASK 255.255.192.0 $openVpnIp
route -p add 192.168.128.0 MASK 255.255.128.0 $openVpnIp
route -p add 10.0.0.0 MASK 255.0.0.0 $openVpnIp

# Configura o RDP par porta 9081
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name PortNumber -value 9081

# Ativa o Remote Desktop
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -value 0

# Ativa a regra para permitir resposta ao ping ativando todas as regras do grupo "Diagnóstico do Sistema de Rede Básico"
Get-NetFirewallRule -DisplayGroup "Diagnóstico do Sistema de Rede Básico" | Set-NetFirewallRule -Enabled True

# Cria regra de firewall permitindo RDP para todas as redes na porta 9081
New-NetFirewallRule -DisplayName "Área de Trabalho Remota - Modo de UsuÃ¡rio (TCP-Entrada-9081)" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9081 -Profile Any -Program Any -Service Any -Enabled True
New-NetFirewallRule -DisplayName "Área de Trabalho Remota - Modo de UsuÃ¡rio (UDP-Entrada-9081)" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 9081 -Profile Any -Program Any -Service Any -Enabled True

Write-Host ("~" * $colunas) -ForegroundColor Green
Write-Host "Para acesso remoto via RDP utilize agora a porta 9081." 
Write-Host ("~" * $colunas) -ForegroundColor Green
Write-Host "Reiniciar o computador agora? (S/N)"
$confirm = Read-Host
if ($confirm -ne "S") {
    exit
}

# Reinicializa o computador
Restart-Computer -Force
