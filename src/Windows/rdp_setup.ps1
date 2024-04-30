<#
.DESCRIPTION
    This script will install the RDP feature on a Windows Server.
    - set the RDP port to 9081
    - enable Remote Desktop
    - create a new firewall rule to enable RDP from all networks in port 9081
    - restart the computer

.PARAMETER config.json
    Parameters are loaded from config.json file include:
    - RDP port
    - Remote Desktop firewall rule name
    - Verbosity level
    - Log file path

.EXAMPLE
    .\rdp_setup.ps1

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