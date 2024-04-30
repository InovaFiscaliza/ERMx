<#
.DESCRIPTION
    This script will install the Storage Manger Service - SMS.
    This include the following steps:
    - Test if the service is already running
        - if so, prompt the user with a pop-up window to uninstall or fix service installation
            - if required to unintall, remove service.
            - if required to fix, remove service and install again.
        - if not, install the service
            - Copy the service files to the target folder
            - Create required folders
            - Create a new service and set it to start automatically
            - Start the service
            - Create an icon on the task bar to run the service GUI

.PARAMETER config.json
    Parameters are loaded from config.json file include:
    - RDP port
    - Remote Desktop firewall rule name
    - Verbosity level
    - Log file path

.EXAMPLE
    .\smd_setup.ps1

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