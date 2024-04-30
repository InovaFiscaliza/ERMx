<#
.DESCRIPTION
    This script will configure a windows machine to be used as an ERMX server.
    - load parameters from a configuration file
    - create operator accounts
    - install ERMX software (appColeta)
    - run ovpn_setup.ps1 script
    - run proxy_setup.ps1 script
    - run rdp_setup.ps1 script
    - run openssh_setup.ps1 script
    - run smd_setup.ps1 script

.PARAMETER config.json
    Parameters are loaded from config.json file include:
    - Verbosity level
    - Log file path

.EXAMPLE
    .\install_ermx.ps1

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