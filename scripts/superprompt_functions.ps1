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
    