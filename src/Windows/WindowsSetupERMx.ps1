# Script PowerShell for ERMx Windows Setup


# Use o comando "Set-ExecutionPolicy RemoteSigned" para permitir a execução de scripts não assinados

# Control variables
$version = "1.0" # script version from 16/10/2023
$VPNNetwork = "172.24.0.0/21"

$user = "Fiscal"
$password = "ermx"

# change this to false to execute the script without changing anything
$noDebug = $false
#$noDebug = $true

$Routes = @(
    @{ DestinationNetwork = "192.168.64.0/18"; GatewayIP = "172.24.0.1" },
    @{ DestinationNetwork = "192.168.128.0/17"; GatewayIP = "172.24.0.1" },
    @{ DestinationNetwork = "10.0.0.0/8"; GatewayIP = "172.24.0.1" }
)

# 5000-5009 -> Reservada para acesso a dispositivos de comunicação (roteador, switch, modem, etc)
# 5010-5019 -> Reservado para acesso a dispositivos de controle ambiental e infra (régua inteligente, UPS, alarmes de temperatura, umidade, invasão, câmeras, etc)
# 5020-5029 -> Reservado para dispositivos de controle e processamento (acesso RDP, SSH, Volumes compartilhados em rede, etc)
# 5050-5099 -> Reservado para dispositivos de medição (receptores, analisadores, stream de demoduladores, etc)

$RDPNewPort = "9081"
$TCP_port_proxy = @(
    @{ Name = "Anatel TPLink HTTP"; WANPort = "80"; LANIP = "192.168.1.1"; LANPort = "80" }, 
    @{ Name = "Anatel Elsys HTTP"; WANPort = "8080"; LANIP = "192.168.10.254"; LANPort = "80" } 
    @{ Name = "Anatel FSL6 RDP"; WANPort = "9083"; LANIP = "192.168.1.60"; LANPort = "3389" }, 
    @{ Name = "Anatel SA2500 Remote"; WANPort = "21005"; LANIP = "192.168.1.60"; LANPort = "21005" },
    @{ Name = "Anatel Volt HTTP"; WANPort = "9082"; LANIP = "192.168.1.80"; LANPort = "80" },     
    @{ Name = "Anatel EB500 Gui"; WANPort = "5555"; LANIP = "192.168.1.60"; LANPort = "21005" },
    @{ Name = "Anatel EB500 Gui"; WANPort = "24001"; LANIP = "192.168.1.60"; LANPort = "21005" },    
    @{ Name = "Anatel RFeye HTTP"; WANPort = "4040"; LANIP = "192.168.1.90"; LANPort = "80" }, 
    @{ Name = "Anatel RFeye NCP"; WANPort = "9999"; LANIP = "192.168.1.90"; LANPort = "9999" }, 
    @{ Name = "Anatel RFeye Logger HTTP"; WANPort = "4041"; LANIP = "192.168.1.90"; LANPort = "8080" }, 
    @{ Name = "Anatel RFeye SSH"; WANPort = "2828"; LANIP = "192.168.1.90"; LANPort = "2828" }
)

# Print script header message
$colunas = $Host.UI.RawUI.BufferSize.Width
Write-Host "`n"
Write-Host ("~" * $colunas) -ForegroundColor Green
Write-Host "Script para configurar computadores Windows para uso em rede como ERMx" -ForegroundColor Green
Write-Host "Versão: $version" -ForegroundColor Green
Write-Host ("~" * $colunas) -ForegroundColor Green
Write-Host "`nPre-requisitos:"
Write-Host "    - Certifique-se que foi habilitado o auto-boot com ativação da energia AC na BIOS"
Write-Host "    - Certifique-se que este computador tenha sido formatado e encontra-se com a instalação limpa do Windows (e atualizado ate a versão 22H2 ou superior)"
Write-Host "    - Certifique-se que esta máquina tenha sido inicializada com perfil administrador local"
Write-Host "    - Certifique-se que o OpenVPN GUI tenha sido instalado, configurado e conectado com sucesso ao servidor."
Write-Host "    - Certifique-se que a rede local ethernet tenha sido configurada com IP estático na faixa 192.168.0.0/24"
Write-Host "    - Certifique-se que a a variável TCP_port_proxy, definida no início do script, tenha sido ajustada corretament para corresponder à configuração desejada.`n"
Write-Host ("~" * $colunas) -ForegroundColor Green
Write-Host "`nAo terminar o script, o computador será reiniciado.`n"

# print warning if $noDebug is false (no changes will be made)
if (!$noDebug) {
    Write-Host "`n ! Modo de debug habilitado ! Nenhuma alteração será realizada. Modifique a variavel nodebug para true para modificar o sistema.`n" -ForegroundColor Red
}

Write-Host "Deseja continuar? (S/N)"
$confirm = Read-Host
if ($confirm -ne "S") {
    exit
}
Write-Host ("~" * $colunas) -ForegroundColor Green
Write-Host "`n"

# create a restore point
Write-Host "`nCriando um ponto de restauração antes da execução das configurações."
if ($noDebug) {
    Enable-ComputerRestore "C:\"
    Checkpoint-Computer -Description "Ponto de restauração criado pelo script de configuração do ERMx, pré-execução"
}
Write-Host "Ponto de restauração criado pelo script de configuração do ERMx, pre-execução.`n"

# configure openvpn client to start as a service
if ($noDebug) {
    Set-Service -Name "OpenVPNService" -StartupType Automatic
}
Write-Host "`nOpenVPN habilitado como serviço, com inicialização automática com o Windows.`n "

# Create a user account with the login "Fiscal" and password "ermx"
if ($noDebug) {
    New-LocalUser -Name $user -Password (ConvertTo-SecureString $password -AsPlainText -Force) -FullName "Fiscalização Anatel" -Description "Usuário para uso em fiscalização da Anatel" -NoPasswordExpiration
}
Write-Host "`nCriado usuário $user no Windows para uso em fiscalização (Senha: $password).`n"

# disable automatic windows update
if ($noDebug) {
    stop-Service wuauserv
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -value 1
}
Write-Host "`nDesabilitadas as atualizações automaticas do Windows Update.`n"

# Enable auto logon for default user and password
if ($noDebug) {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -value "Fiscal"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -value "ermx"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -value 1
}
Write-Host "`nHabilitado o logon automático do usuário criado.`n"

# Get the network interface for the specified IP range used by OpenVPN
$Interface = Get-NetRoute | Where-Object { $_.DestinationPrefix -eq "$VPNNetwork" }

# Check if the interface was found and add the routes
if ($null -eq $Interface) {
    Write-Host "`nSem interface para OpenVPN. Verifique a conexao VPN e tente novamente.`n"
}
else {
    foreach ($RouteInfo in $Routes) {
        $DestinationNetwork = $RouteInfo.DestinationNetwork
        $GatewayIP = $RouteInfo.GatewayIP

        # Add a route using the interface ID and gateway IP
        if ($noDebug) {
            New-NetRoute -DestinationPrefix "$DestinationNetwork" -InterfaceIndex $Interface.InterfaceIndex -NextHop $GatewayIP -RouteMetric 1
        }

        Write-Host "Adicionada rota $DestinationNetwork via $GatewayIP na interface $($Interface.InterfaceAlias) (ID: $($Interface.InterfaceIndex))."
    }
}


if ($noDebug) {
    # Configure RDP port to RDP new port as defined in $RDPNewPort
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name PortNumber -value $RDPNewPort

    # Activate RDP service
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -value 0

    # Create new rule for RDP port 9081
    New-NetFirewallRule -DisplayName "Area de Trabalho Remota - Modo de Usuário (TCP-Entrada-9081)" -Direction Inbound -Action Allow -Protocol TCP -LocalPort $RDPNewPort -Profile Any -Program Any -Service Any -Enabled True
    New-NetFirewallRule -DisplayName "Area de Trabalho Remota - Modo de Usuário (UDP-Entrada-9081)" -Direction Inbound -Action Allow -Protocol UDP -LocalPort $RDPNewPort -Profile Any -Program Any -Service Any -Enabled True
}
Write-Host "`nAtivado servico de Area de Trabalho Remota na porta $RDPNewPort.`n"

# Configure port proxy for various aditional TCP services
foreach ($TCP in $TCP_port_proxy) {

    $name = $TCP.Name
    $WANPort = $TCP.WANPort
    $LANIP = $TCP.LANIP
    $LANPort = $TCP.LANPort

    # Create new rule for TCP port proxy
    if ($noDebug) {
        netsh interface portproxy add v4tov4 listenport=$WANPort listenaddress=0.0.0.0 connectport=$LANPort connectaddress=$LANIP
        New-NetFirewallRule -DisplayName $Name -Direction Inbound -Action Allow -Protocol TCP -LocalPort $WANPort -RemoteAddress Any -Profile Any -Program Any -Service Any -Enabled True
    }
    Write-Host "Ativada port proxy $Name `b: $WANPort -> $LANIP `b:$LANPort.`n"
}

# Activate firewall rule to enable ping response
if ($noDebug) {
    Get-NetFirewallRule -name "CoreNet-Diag-ICMP4-EchoRequest-In-NoScope" | Set-NetFirewallRule -Enabled True -Profile Any -RemoteAddress "10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"
}

# Change network interface for network 172.24.0.0 as "rede privada"
if ($noDebug) {
    Set-NetConnectionProfile -InterfaceAlias $Interface.InterfaceAlias -NetworkCategory Private
}

Write-Host "`nOpenVPN configurada como rede privada e ativada regra no firewall para resposta a ping.`n"

# create a restore point
Write-Host "`nCriando um ponto de restauração apos a execução das configurações."
if ($noDebug) {
    Checkpoint-Computer -Description "Ponto de restauração criado pelo script de configuração do ERMx, pós-execução"
}
Write-Host "Ponto de restauração criado pelo script de configuração do ERMx, pos-execução.`n"

Write-Host ("~" * $colunas) -ForegroundColor Green
# printe warning if debug mode is enabled (no changes will be made)
if ($noDebug) {
    Write-Host "Para acesso remoto via RDP utilize agora a porta $RDPNewPort."
}
else {
    Write-Host "Modo de debug habilitado. Nenhuma alteração foi realizada."
}
Write-Host ("~" * $colunas) -ForegroundColor Green
Write-Host "`nO computador será reiniciado em 10 segundos. Use Ctrl+C para interromper a reinicialização`n" -ForegroundColor Red

# Print countdow to restart for 10 seconds
for ($i = 10; $i -gt 1; $i--) {
    Write-Host "Reiniciando em $i segundos..." -ForegroundColor Red
    Start-Sleep -Seconds 1
}
Write-Host "Reiniciando em 1 segundo..." -ForegroundColor Red
Start-Sleep -Seconds 1

# Restart computer
if ($noDebug) {
    Restart-Computer -Force
}