<#
.DESCRIPTION
    Configure OpenVPN client by performing the following tasks:
    - Load configuration parameters from config.json
    - If OpenVPN client is not installed, install it
    - If OpenVPN client and version is obsolete, update it
    - Download the OpenVPN configuration file using user credentials
    - Configure the OpenVPN with the downloaded configuration file
    - Configure the OpenVPN service to start automatically
    - Start the OpenVPN service
    - Test the OpenVPN connection

.PARAMETER config.json
    Parameters are loaded from config.json file include:
    - OpenVPN URL
    - Configuration file URL
    - Remote Desktop firewall rule name
    - Verbosity level
    - Log file path

.EXAMPLE
    .\ovpn_setup.ps1

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

# check if OpenVPN client is installed
if (-not (Get-Command -Name "openvpn" -ErrorAction SilentlyContinue)) {
    Write-Host "OpenVPN client not found. Installing OpenVPN client..."
    # Install OpenVPN client
    choco install openvpn -y
}

# Install SharePointPnPPowerShellOnline module if not already installed
# Keys and instalation files are stored in sharepoint folders

if (-not (Get-Module -Name SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue)) {
    Install-Module -Name SharePointPnPPowerShellOnline -Force -AllowClobber
}

# Connect to SharePoint with MFA authentication
Connect-PnPOnline -Url "<SharePoint Site URL>" -UseWebLogin

# Define the SharePoint file URL
$sourceUrl = "<SharePoint File URL>"

# Define the local file path to save the downloaded file
$destinationPath = "<Local File Path>"

# Download the file from SharePoint
Get-PnPFile -Url $sourceUrl -Path $destinationPath

# Disconnect from SharePoint
Disconnect-PnPOnline
