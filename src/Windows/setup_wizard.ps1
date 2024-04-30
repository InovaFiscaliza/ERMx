<#
.DESCRIPTION
    This script will install the package of PowerShell scripts using a GUI that allows users to select a script to run and configure parameters.

.PARAMETER config.json
    Parameters are loaded from config.json file include:
    - GUI start width and height
    - Verbosity level
    - Log file path

.EXAMPLE
    .\setup_wizard.ps1

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

# Load the required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create a form
$form = New-Object System.Windows.Forms.Form
$form.Text = "PowerShell GUI Application"
$form.Size = New-Object System.Drawing.Size($config.GUI.start_width,$config.GUI.start_height)
$form.StartPosition = "CenterScreen"

# Create labels
$label1 = New-Object System.Windows.Forms.Label
$label1.Location = New-Object System.Drawing.Point(10,20)
$label1.Size = New-Object System.Drawing.Size(280,20)
$label1.Text = "Select a script to run:"

# Create a dropdown list
$comboBox = New-Object System.Windows.Forms.ComboBox
$comboBox.Location = New-Object System.Drawing.Point(10,50)
$comboBox.Size = New-Object System.Drawing.Size(280,20)
$comboBox.DropDownStyle = 'DropDownList'
$comboBox.Items.AddRange(@("Script 1", "Script 2", "Script 3"))

# Create a button
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(100,100)
$button.Size = New-Object System.Drawing.Size(100,40)
$button.Text = "Run Script"
$button.Add_Click({
    # Retrieve selected script from the dropdown list
    $selectedScript = $comboBox.SelectedItem.ToString()
    
    # Run the selected script (replace with actual script execution code)
    Write-Host "Running script: $selectedScript"
})

# Add controls to the form
$form.Controls.Add($label1)
$form.Controls.Add($comboBox)
$form.Controls.Add($button)

# Show the form
$form.ShowDialog() | Out-Null
