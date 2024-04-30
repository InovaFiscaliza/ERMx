<#
.DESCRIPTION
    This script will manage files in selected folders.
    Files are indexed in TXT list files, allowing for integration with [RF.Fusion](https://github.com/InovaFiscaliza/RF.Fusion/blob/main/src/agent/README.md)
    Older files are deleted when the available disk space is below a certain threshold.
    To achieve this, the script perform the following tasks:
        - Load configuration parameters from config.json
        - try to raise the halt flag (HALT_FLAG cookie file).
            - If the flag is raised, check if it is older than the HALT_TIMEOUT.
                - If so, the service will pause for HALT_TIMEOUT seconds before checking the flag again.
                - If not, reset the flag (take the flag for itself) and continue the service.
        - Check if listed folders are shared through the network
            - if not shared, share the folders
        - Check the available disk space
            - if below the threshold, delete older files from the BACKUP_DONE list file, updating the file afterwards
                - Delete as many files as needed to reach the TARGET_SPACE_THRESHOLD
        - Check for changed files
            - if changed, update the DUE_BACKUP list file 

.PARAMETER config.json
    Parameters are loaded from config.json file 

        - TARGET_FOLDERS - list of folders to be indexed
        - MINIMUM_SPACE_THRESHOLD - minimum disk space available in bytes before deleting older files
        - TARGET_SPACE_THRESHOLD - target disk space available in bytes after deleting older files
        - VERBOSITY - level of verbosity
        - DAEMON_FOLDER - folder where the daemon state files are stored, including the following files:
            - TEMP_CHANGED - temporary file to store the list of changed files
            - DUE_BACKUP - file containing a list of files to be backed up
            - BACKUP_DONE - file containing a list of files that have been backed up
            - HALT_FLAG - cookie file to pause the service
            - HALT_TIMEOUT - time to wait before checking the HALT_FLAG again and release the service to continue
            - LAST_FILE_SEARCH_FLAG - cookie file to store the last file search time
            - LOG_FILE - path to the log file

.EXAMPLE
    .\store_manage_service.ps1

.NOTES
    By E! SFI Anatel, 2024.
#>

$DEFAULT_CONFIG_FILE = "config.json"

# Check if the configuration file exists
if (-not (Test-Path $DEFAULT_CONFIG_FILE)) {
    Write-Error "Configuration file not found: $DEFAULT_CONFIG_FILE"
    exit 1
}

# Read the content of the JSON configuration file
$config = Get-Content -Raw -Path $DEFAULT_CONFIG_FILE | ConvertFrom-Json