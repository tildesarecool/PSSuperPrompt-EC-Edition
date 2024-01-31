# example sym link lines. 
# I use <imaginary> <real> as the mnemonic
#  cmd /c mklink C:\Users\tildes\Documents\PowerShell\Scripts\prompt-ec.ps1 "C:\Users\tildes\Documents\repos\PSSuperPrompt-EC-Edition\scripts\prompt.ps1"
#  cmd /c mklink C:\Users\tildes\Documents\PowerShell\Scripts\prompt-orginal.ps1 "C:\Users\tildes\Documents\repos\PSSuperPrompt\prompt.ps1"
#  cmd /c mklink "C:\Users\tildes\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" "C:\Users\tildes\Documents\repos\PSSuperPrompt-EC-Edition\scripts\PS profile default script.ps1"
#  cmd /c mklink C:\Users\tildes\Documents\PowerShell\superprompt_functions.ps1 C:\Users\tildes\Documents\repos\PSSuperPrompt-EC-Edition\scripts\superprompt_functions.ps1

# Import custom scripts
$customScriptsFolder = Join-Path (Split-Path $profile) "Scripts"
#######Get-ChildItem -Path $customScriptsFolder -Filter "*.ps1" | ForEach-Object { . $_.FullName }
#Get-ChildItem -Path $customScriptsFolder -Filter "*-ec.ps1" | ForEach-Object { . $_.FullName }
Get-ChildItem -Path $customScriptsFolder -Filter "*-orginal.ps1" | ForEach-Object { . $_.FullName }