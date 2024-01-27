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

function DetermineGitInstalled {
    GitMissing = $true
    if ( (Get-Command git  -ErrorAction SilentlyContinue)  ) { 
        GitMissing = $false
    } else {
        GitMissing = $true
    }
    return GitMissing
}
$Global:gitStatus = DetermineGitInstalled

function DeterminPSVersion {
    # this should make $ver a string that is the version PS installed
    # something like "7.4.0"
    $ver = [string]$PSVersionTable.PSVersion
    #([string]$PSVersionTable.PSVersion).Split('.')[0..1] -join '.'
    #    $jobs = Get-Job
    return $ver

}

function ReturnLastTime {
    $ver = [string](DeterminPSVersion)[0]    
    if ($ver[0] -ge 7) {
            # $ver[0] 
            $lastTime = Get-LastHistoryDuration
        } else {
            Write-Host "Unclear if this will run on PS versions early than 7, but I'll continue anyway."
            $lastTime = Get-LastHistoryDuration
        }
    return $lastTime
    
}


function Get-LastHistoryDuration
{
    if ((Get-History).Count -gt 0)
    {
        $duration = (Get-History)[-1].Duration
        # Use the int portion of TotalHours because we're not doing Days
        $hours = ([decimal]$duration.TotalHours).ToString().Split('.')[0]
        $hours = $hours.PadLeft(2, '0')
        
$minutes = $duration.Minutes.ToString().PadLeft(2, '0')
$seconds = $duration.Seconds.ToString().PadLeft(2, '0')
$milliseconds = $duration.Milliseconds.ToString().PadLeft(3, '0')
$output = "$($seconds).$($milliseconds)"
        
        if ($minutes -ne '00') {
            $output = "$($minutes):$($output)"        
        }
        if ($hours -ne '00') {
            $output = "$($hours):$($output)"
        }
        
        return $output
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
         Write-Host "[System.Security.Principal.WindowsBuiltInRole]::Administrator is " $adminRole
         $admin = $principal.IsInRole($adminRole)
         Write-Host "admin after isinroll is" $admin
     } else {
         Write-Host "I dunno what OS you have"
         $admin = $false
      #   Write-Host $admin
     }
 
     Write-Host $admin
     return $admin
 }



function TestForPosh {
    if (get-module -Name posh* -ListAvailable -Verbose:$false) { 
        Write-Host "found posh git" 
        return $true
    } else { 
        Write-Host "did not find posh git, exiting...." 
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

# rather than testing aginst running Get-GitStatus I just test against whether or not the git command runs or not
$Global:__poshGitInstalled = TestForPosh -and $gitStatus
$Global:jobs = Get-Job
function Global:prompt {

    $wd = setWorkDir # (Get-Location).Path
    # rather than splicing up the 'whoami' command you "could" refer to the %USERNAME$ environment variable. At least on windows
    # I assume there's an equivalent env var under Linux but I don't know if it would be accessed the same way via PS 
    #$user = (whoami).Split('\')[-1]
    $user = $env:USERNAME
    # $hostname = hostname # redundant variable of redundancy is redundant

    # Extra versiony goodness:
    # forker speaking: I'm not sure what the purpose of this bit is. It appears to appened ".0" to the end of the $ver variable if the patch number is not $null
    # Since I've implement my own version of this determining the PS version this does not seem necessary
    # so i'm commenting it out and I"ll just have to see if anything breaks in my own fork version
    #if ($null -ne $PSVersionTable.PSVersion.Patch) {
    #    $ver += ".$($PSVersionTable.PSVersion.Patch)"
    #}
    
#    $admin = $false
#    if ($IsLinux -and $user -eq 'root')
#    {
#        $admin = $true
#    }
#    elseif (!$IsLinux)
#    {
#        $admin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
#    }
    
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
    
    # History count:
    Write-Host "$(((Get-History).Count + 1).ToString().PadLeft(3, '0')) " -NoNewline
    # PS Version:
    if ($PSVersionTable.PSVersion.PreReleaseLabel) {
        Write-Host "($($ver)-$($PSVersionTable.PSVersion.PreReleaseLabel)) " -ForegroundColor Red -NoNewline
    }
    else {
        Write-Host "($ver) " -ForegroundColor Magenta -NoNewline
    }
    # Timestamp:
    Write-Host "[$(([string](Get-Date)).Split()[1])] " -ForegroundColor Yellow -NoNewline
    
    # Last Execution Time: ReturnLastTime
    $lastTime = ReturnLastTime
    if ($ver -ge 7 -and $lastTime) {
        Write-Host "<$($lastTime)> " -ForegroundColor Blue -NoNewline
    }
    
    # Job control:
    if ($jobs) {
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
    
    if ($gitStatus) {
        Write-Host '[GIT] ' -ForegroundColor Green -NoNewline
    }
    else  {
        
        if ($admin)  {
            Write-Host "$($user)" -ForegroundColor Red -NoNewLine
        }
        else  {
            Write-Host "$($user)" -ForegroundColor Green -NoNewLine
        }
        Write-Host " @ " -ForegroundColor Yellow -NoNewLine
        #Write-Host "$($hostname) " -ForegroundColor Magenta -NoNewLine
        # bro, 
        Write-Host "$(hostname) " -ForegroundColor Magenta -NoNewLine
        # works as well. the hostname variable seems redundant
    }
    if ($admin)  {
        $sym = '#'
    }
    else {
        $sym = '$'
    }
    Write-Host "$($wd) " -ForegroundColor Cyan -NoNewLine
    if ($gitStatus) {
        Write-Host "`b" -NoNewline
        Write-Host (Write-VcsStatus) -NoNewline
    }
    #>
    Write-Host ''
    Write-Host "$($sym)" -ForegroundColor Cyan -NoNewLine
    return ' '
}

Invoke-Expression "function Reset-Prompt { . '$($MyInvocation.MyCommand.Path)' }"
New-Alias -Name 'rsp' -Value 'Reset-Prompt' -Force
