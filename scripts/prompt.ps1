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
$originalPromptFunction = $function:prompt

function DetermineGitInstalled {
# decided to get with the much shorter approach this time
# I mean "technically" I could simply set a global variable to this literal exact line
# and that would do the same thing but this is fine too
    return (Get-Command git) 

}


function DeterminePSVersion {
    # this should make $ver a string that is the version PS installed
    # something like "7.4.0"
    $psver = [string]$PSVersionTable.PSVersion
    #([string]$PSVersionTable.PSVersion).Split('.')[0..1] -join '.'
    #    $jobs = Get-Job
 #   Write-Host $psver
    return $psver

}
#DeterminePSVersion


function ReturnLastTime {
    $majorpsver = [string](DeterminePSVersion)[0]  #should be the string version of the whole version number, for instance "7.4.1"
    if ($majorpsver[0] -ge 7) {
            # element 0 of this string should be the version digit of the number version number, e.g. 7 for the version 7.4.1
            # although testing the value again what is clearly the integer 7 is some kind of implicit typecasting.
            # either that or PS compares strings to ints no problemo
            $lastHistDur = Get-LastHistoryDuration
        } else {
            Write-Host "Unclear if this will run on PS versions early than 7, but I'll continue anyway."
            $lastHistDur = Get-LastHistoryDuration
        }
    return $lastHistDur
    
}


function Get-LastHistoryDuration {
# i really re-wrote this from scratch. Yep. Just me on my own. That's my story and I'm sticking to it
    $lastEntry = (Get-History | Select-Object -Last 1)
    
    if ($lastEntry) {
        $duration = $lastEntry.Duration
        return (Measure-Command { $duration }).ToString("hh\:mm\:ss\.fff")
    }
}


function Test-Administrator {
    # $admin = $false
     
#    if ($IsLinux -and $user -eq 'root')
#    {
#        $admin = $true
#    }
    $EUID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
# I got this $EUID bit from chatGPT. And since she's almost never wrong so I'm just assuming it's a valid
# way to determine the yes/no ....root-ness.... access level
     if ($IsLinux -and $user -eq 'root' -and $EUID -eq '0') {

            $admin = $true

        } elseif ($IsWindows) {
         $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
         $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
         
         $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
         #Write-Host "[System.Security.Principal.WindowsBuiltInRole]::Administrator is " $adminRole
         $admin = $principal.IsInRole($adminRole)
         #Write-Host "admin after isinroll is" $admin
     } else {
         Write-Host "I dunno what OS you have"
         $admin = $false
      #   Write-Host $admin
     }
 
     #Write-Host $admin
     return $admin
 }


 
function TestForPosh {
    if (get-module -Name posh-gi* -ListAvailable -Verbose:$false) { 
        #Write-Host "found posh git" 
        return $true
    } else { 
        #Write-Host "did not find posh git, exiting...." 
        return $false
        
    }
}


function setWorkDir {
    $workdir = (Get-Location).Path
    if ($workdir -eq $HOME) {
        $workdir = '~'
    } elseif ($workdir.Split('\')[-1] -ne '' -and !$gitStatus)    {
        $workdir = $workdir.Split('\')[-1]
    } elseif ($gitStatus -and $workdir -like '*::*') {
        $workdir = $workdir.Split(':')[-1]
    }
    return $workdir
}

function DeterHistCount { 
    # return is implicit here so it's not necessary. 
    # I've added it just for readibility
    return ((Get-History).Count + 1).ToString().PadLeft(3, '0') 
}

function GetPSverPRLabel {
    # GetPSverPRLabel
    $GetPSVerPreLabel = $PSVersionTable.PSVersion.PreReleaseLabel
    if ($GetPSVerPreLabel) {
        $result = "($($PSFullVer)-$($GetPSVerPreLabel))" #   -ForegroundColor Red -NoNewline"
    }
    else {
        $result = "($PSFullVer)" #  -ForegroundColor Magenta -NoNewline"
    }
    return $result

}


function Show-JobStatus {

    if ($jobs) {
        # The color-coded output in the Write-Host statements is providing a visual representation of the job states and their counts:
        # Cyan: Running jobs.
        # Red: Completed jobs with more data in their result streams.
        # Green: Completed jobs without more data in their result streams.

        $r = $jobs.where({$_.State -eq 'Running'}).count
        $d = $jobs.where({$_.State -eq 'Completed' -and $_.HasMoreData}).count
        $c = $jobs.where({$_.State -eq 'Completed' -and -not $_.HasMoreData}).count
        
        $jobCounter = "jobs($($c)/$($jobs.Count))"
        
        Write-Host '[' -NoNewline -ForegroundColor Yellow
        if ($d) {
            Write-Host $jobCounter -NoNewline -ForegroundColor Red
        }
        elseif ($c -eq $jobs.Count) {
            Write-Host $jobCounter -NoNewline -ForegroundColor Green
        }
        else {
            Write-Host $jobCounter -NoNewline -ForegroundColor Cyan
        }
        Write-Host ' : ' -NoNewline -ForegroundColor Gray
        # Running
        Write-Host ">$r " -NoNewline -ForegroundColor Cyan
        # HasData
        Write-Host "!$d " -NoNewline -ForegroundColor Red
        # Complete
        Write-Host "`$$c" -NoNewline -ForegroundColor Green
        
        Write-Host '] ' -NoNewline -ForegroundColor Yellow
    }

}

function SetAdminAccessDefaultSettings {
    if ($admin)  {
        Write-Host "$($user)" -ForegroundColor Red -NoNewLine
        $sym = '#'
    }
    else  {
        Write-Host "$($user)" -ForegroundColor Green -NoNewLine
        $sym = '$'
    }
    Write-Host " @ " -ForegroundColor Yellow -NoNewLine
    #Write-Host "$($hostname) " -ForegroundColor Magenta -NoNewLine
    # bro, 
    Write-Host "$($hostname) " -ForegroundColor Magenta -NoNewLine

    Write-Host ''
    Write-Host "$($sym)" -ForegroundColor Cyan -NoNewLine
}
    # works as well. the hostname variable seems redundant
# }
#    if ($admin)  {
#        $sym = '#'
#    }
#    else {
#        $sym = '$'
#    }



#$Global:PSFullVer = DeterminePSVersion
# rather than testing aginst running Get-GitStatus I just test against whether or not the git command runs or not
$Global:__poshGitInstalled = TestForPosh -and $gitStatus
$Global:jobs = Get-Job
$Global:gitStatus = DetermineGitInstalled
$Global:admin = Test-Administrator
$Global:wd = setWorkDir
#$Global:user = $env:USERNAME
# Ternaries are "tight"
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

    return ' '
}


# after prompt function definition
# Reset-Prompt function definition
function Reset-Prompt {
    $function:prompt = $originalPromptFunction
}

# Create an alias for Reset-Prompt
New-Alias -Name 'rsp' -Value 'Reset-Prompt' -Force


#Invoke-Expression "function Reset-Prompt { . '$($MyInvocation.MyCommand.Path)' }"
#New-Alias -Name 'rsp' -Value 'Reset-Prompt' -Force

# I found this alt approach to resetting back to original prompt. Looks like some of it is prior to the prompt function and
# some of it afterwards. This should save the current prompt for later restoration when resetting.

#$originalPromptFunction = $function:prompt

# Override the prompt function with your custom logic
#function Global:prompt {
#    "My Custom Prompt > "
#}

# Define the Reset-Prompt function
#function Reset-Prompt {
#    $function:prompt = $originalPromptFunction
#}

# Create an alias for Reset-Prompt
#New-Alias -Name 'rsp' -Value 'Reset-Prompt' -Force





    # Extra versiony goodness:
    # forker speaking: I'm not sure what the purpose of this bit is. It appears to appened ".0" to the end of the $ver variable if the patch number is not $null
    # Since I've implement my own version of this determining the PS version this does not seem necessary
    # so i'm commenting it out and I"ll just have to see if anything breaks in my own fork version
    #if ($null -ne $PSVersionTable.PSVersion.Patch) {
    #    $ver += ".$($PSVersionTable.PSVersion.Patch)"
    #}


    # the Get-GitStatus command doesn't exist by default. It probably comes with the posh-git module
    # so stating posh-git is optional may be misleading slightly.
    # this line I commented out
    # $gitStatus = $Global:__poshGitInstalled -and (Get-GitStatus)
    # after looking at the only file that contains Get-GitStatus on the posh-git repo,
    # i am just guessing it shows the status of corrently selected git repo as opposed to just returning whether or not
    # git is installed or not
    
################ Since I don't know what these few lines below does i'm commenting them out ################ 

#    elseif ($wd.Split('\')[-1] -ne '' -and !$gitStatus)
#    {
#        $wd = $wd.Split('\')[-1]
#    }
#    elseif ($gitStatus -and $wd -like '*::*')
#    {
#        $wd = $wd.Split(':')[-1]
#    }

################ Since I don't know what these few lines below does i'm commenting them out ################ 