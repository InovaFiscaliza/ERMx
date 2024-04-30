<#
.DESCRIPTION
    Configure proxy rules that enable the access to LAN services through the PC, mostly useful when the PC operates as gateway for the LAN services to OpenVPN remote clients.
    It performs the following tasks
    - Load a list of TCP services and ports from config.json
    - Create a port proxy rule using netsh
    - Create a firewall rule to allow the port proxy

.PARAMETER config.json
    Parameters are loaded from config.json file include:
    - Service List, with configuration for each service
    - Verbosity level
    - Log file path

.EXAMPLE
    .\proxy_setup.ps1

.NOTES
    E! SFI Anatel, 2024
#>


$DEFAULT_CONFIG_FILE = "config.json"

# Check if the configuration file exists
if (-not (Test-Path $DEFAULT_CONFIG_FILE)) {
    Write-Error "Configuration file not found: $DEFAULT_CONFIG_FILE"
    exit 1
}

# Read the content of the JSON configuration file
$config = Get-Content -Raw -Path $DEFAULT_CONFIG_FILE | ConvertFrom-Json

# create port proxy for windows services using netsh

$TCP_port_proxy = @(
    @{ Name = "Zabbix HTTP"; InPort = "80"; OutIP = "172.16.18.101"; OutPort = "80" }, 
    @{ Name = "SenhaSegura SSH"; InPort = "22"; OutIP = "192.168.10.101"; OutPort = "22" }
)

# Configure port proxy for various aditional TCP services
foreach ($TCP in $TCP_port_proxy) {

    $name = $TCP.Name
    $InPort = $TCP.InPort
    $OutIP = $TCP.OutIP
    $OutPort = $TCP.OutPort

    # Create new rule for TCP port proxy
    if ($noDebug) {
        netsh interface portproxy add v4tov4 listenport=$InPort listenaddress=0.0.0.0 connectport=$OutPort connectaddress=$OutIP
        New-NetFirewallRule -DisplayName $Name -Direction Inbound -Action Allow -Protocol TCP -LocalPort $InPort -RemoteAddress Any -Profile Any -Program Any -Service Any -Enabled True
    }
    Write-Host "Ativada port proxy $Name `b: $InPort -> $OutIP `b:$OutPort.`n"
}
