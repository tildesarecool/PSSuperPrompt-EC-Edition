# mklink C:\Users\tildes\Documents\PowerShell\Scripts\prompt-ec.ps1 "C:\Users\tildes\Documents\repos\PSSuperPrompt-EC-Edition\prompt.ps1"
# mklink C:\Users\tildes\Documents\PowerShell\Scripts\prompt-orginal.ps1 "C:\Users\tildes\Documents\repos\PSSuperPrompt\prompt.ps1"

# Import custom scripts
$customScriptsFolder = Join-Path (Split-Path $profile) "Scripts"
# Get-ChildItem -Path $customScriptsFolder -Filter "*.ps1" | ForEach-Object { . $_.FullName }
Get-ChildItem -Path $customScriptsFolder -Filter "*-ec.ps1" | ForEach-Object { . $_.FullName }
#Get-ChildItem -Path $customScriptsFolder -Filter "*-orginal.ps1" | ForEach-Object { . $_.FullName }