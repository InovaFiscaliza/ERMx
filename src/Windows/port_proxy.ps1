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
