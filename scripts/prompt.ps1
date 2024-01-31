# have to speculate on the purpose of these two lines
# I think it's a double test against poshgit module being installed:
# the first test with the get-module of posh-git is test
#$Global:__poshGitInstalled = [bool](Get-Module -Name posh-git -ListAvailable -Verbose:$false)
# and the second test combines with "Get-GitStatus" for this $gitstatus variable
#$gitStatus = $Global:__poshGitInstalled -and (Get-GitStatus)
# later in the script, it tests against $gitStatus to perform further tests
# But since I don't have sample output of what Get-GitStatus returns I'm kind of guessing
# so it could be it's saying "make sure the posh-git module is installed then also get result of a Get-GitStatus command"
# assuming that Get-GitStatus would return false or non-true if it failed. which seems unnecessary
# so I'm taking over the gitstatus variable to simply check if git-for-windows is installed or not instead
# a function posh-git already wrote out so I'm going to "borrow" it

# intended to "backup" prompt as it currently is
# this doesn't work so i'm taking it out
#$originalPromptFunction = $function:prompt

    # works as well. the hostname variable seems redundant

    $functionscriptpath = ".\superprompt_functions.ps1"

if ( test-path  $functionscriptpath -pathtype Leaf ) {
        
    Write-Host "script found"
    Write-Host "value of functionscriptpath is " $functionscriptpath
    . $functionscriptpath

    } else {
        
        Write-Host "not found - value of functionscriptpath is " $functionscriptpath
    Write-Host "script not found"
        break
}

#$Global:PSFullVer = DeterminePSVersion
# rather than testing aginst running Get-GitStatus I just test against whether or not the git command runs or not
$Global:__poshGitInstalled = TestForPosh -and $gitStatus
$Global:jobs = Get-Job
$Global:gitStatus = DetermineGitInstalled
$Global:admin = Test-Administrator
$Global:wd = setWorkDir
#$Global:user = $env:USERNAME
# Ternaries are "tight"...apparently PS 5 doesn't support ternaries. So I'll add an if/else version check later. Or just make the minimum version of PS 7.x.
$Global:user = $IsWindows ? $env:USERNAME : ($IsLinux ? $env:USER : ($IsMacOS ? $env:USER : $null))
$Global:hostname = $IsWindows ? $env:COMPUTERNAME : ($IsLinux ? $env:HOSTNAME : ($IsMacOS ? $env:HOSTNAME : $null))
$Global:gethistcount = DeterHistCount
$Global:PSFullVer = DeterminePSVersion
$Global:lastTime = ReturnLastTime
$Global:GetTimeStamp = "[$(([string](Get-Date)).Split()[1])] "
$Global:SetPSverPRLabel = GetPSverPRLabel

#$Global:lastTime = ReturnLastTime
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

