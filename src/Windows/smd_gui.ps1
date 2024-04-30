<#
.DESCRIPTION
    This script allows the user to manage the SMS service.
    This include the following functions:
    - check the service status
    - change the configuration file setting variables that controls the service
    - start/stop the service

.PARAMETER config.json
    Parameters are loaded from config.json file include:
    - GUI start width and height
    - Service configuration parameters
    - Verbosity level
    - Log file path

.EXAMPLE
    .\smd_gui.ps1

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