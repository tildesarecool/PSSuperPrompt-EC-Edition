# have to speculate on the purpose of these two lines
# I think it's a double test against poshgit module being installed:
# the first test with the get-module of posh-git is test
#$Global:__poshGitInstalled = [bool](Get-Module -Name posh-git -ListAvailable -Verbose:$false)
# and the second test combines with "Get-GitStatus" for this $gitstatus variable
#$gitStatus = $Global:__poshGitInstalled -and (Get-GitStatus)
# later in the script, it tests against $gitStatus to perform further tests
#update: I found the intent behind $gitStatus and it was for something else entirely
# than the name would imply (to me)
# I'll update the readme eventually. Probably.

# intended to "backup" prompt as it currently is
# this doesn't work so i'm taking it out
#$originalPromptFunction = $function:prompt

    # works as well. the hostname variable seems redundant


<#
I decided to move the variable declarations to a text file
and use get-content to bring them in
#>
#if ($declareVars = "$PSScriptRoot\variables.txt") {
#    Write-Host "found variables - "  $declareVars
#}
if ( test-path  $declareVars -pathtype Leaf ) {
    $importVariables = Get-Content -Path $declareVars
    Invoke-Expression -Command ($importVariables -join "`n")

    Write-Host "variables imported successfully"

#    foreach ($varDec in $importVariables) {
#        Remove-Variable -Name $varDec
    }     else {
        Write-Host "Could not find variables.txt. Please add this file (latest available from GitHub repo)"
    }
    

<#
    for ($i = 0; $i -le $importvariables.length; $i++) {
         Remove-Variable -Name varDec
         Write-Host  $varDec

#>

    # Remove all existing variables
#Get-Variable -Scope Global | Where-Object { $_.Visibility -eq 'Public' -and $_.Name -ne 'null' } | Remove-Variable
    # Execute variable declarations
#    Invoke-Expression -Command $importVariables
<#

$importVariables is an array of strings, and Invoke-Expression expects a single string as its argument. 
To resolve this, you can join the array elements into a single string before passing it to Invoke-Expression using
"`n"

#>

#}


    $functionscriptpath = "$PSScriptRoot\superprompt_functions.ps1"

#if ( test-path  $functionscriptpath -pathtype Leaf ) {
if ( $functionscriptpath ) {
        
    Write-Host "script found"
    Write-Host "value of functionscriptpath is " $functionscriptpath
    . $functionscriptpath

    } else {
        Write-Host "value of PSCommandPath is " $PSCommandPath
        Write-Host "not found - value of functionscriptpath is " $functionscriptpath
    Write-Host "script not found"
        break
}





function Global:prompt {

    # Job control: I don't think it matters where in this function I  call this job control so I'm putting it first
    Show-JobStatus
    # History count:
    #Write-Host "$(((Get-History).Count + 1).ToString().PadLeft(3, '0')) " -NoNewline
    # this is more readable perhaps some developers believe
    Write-Host $gethistcount -NoNewline
    # PS Version:
    if ($SetPSverPRLabel) {
        Write-Host $SetPSverPRLabel  -ForegroundColor Red -NoNewline
    } else {
        Write-Host $SetPSverPRLabel -ForegroundColor Magenta -NoNewline
    }

    Write-Host $GetTimeStamp -ForegroundColor Yellow -NoNewline
    
    # Last Execution Time: ReturnLastTime
    # $lastTime defined global above
    if ($PSFullVer -ge 7 -and $lastTime) {
        Write-Host "<$($lastTime)> " -ForegroundColor Blue -NoNewline
    }
    


    
    if ($gitStatus) {
        Write-Host '[GIT] ' -ForegroundColor Green -NoNewline
    }
    #else  {

    SetAdminAccessDefaultSettings
        

    Write-Host "$($wd) " -ForegroundColor Cyan -NoNewLine
    
    if (TestForPosh) {
        # Write-VcsStatus is a posh-git-provided statement, no idea what's supposed to do
        # but since it won't run without posh-git anyway I'll test against the presence of posh-git
        Write-Host "`b" -NoNewline
        Write-Host (Write-VcsStatus) -NoNewline 
    }
    #>

    return '> '
}

# this doens't do what I thought it did so there's no reason for it
# I'm still leaving it here as a place holder
# after prompt function definition
# Reset-Prompt function definition
#function Reset-Prompt {
#    $function:prompt = $originalPromptFunction
#}

# Create an alias for Reset-Prompt
#New-Alias -Name 'rsp' -Value 'Reset-Prompt' -Force

