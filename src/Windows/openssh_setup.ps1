<#
.DESCRIPTION
    This script will configure OpenSSH on Windows, including user authentication and firewall rules.
    - load parameters from a configuration file
    - install OpenSSH if not available
    - create user accounts for SSH authentication
    - share folders for SSH access

.PARAMETER config.json
    Parameters are loaded from config.json file include:
    - SSH port
    - Verbosity level
    - Log file path

.EXAMPLE
    .\openssh_setup.ps1

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