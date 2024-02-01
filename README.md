# PSSuperPrompt "EC Edition"

This is a fork of [PSSuperPrompt](https://github.com/poshcodebear/PSSuperPrompt).

Basic description from @poshcodebear
>Some cool extra tricks for your PowerShell prompt to display more details and colors

My updated idea on what this EC Edition will be: a display immediately above the CLI with various pieces of information. As much of this as possible will be customizable in with what is display in what colors. The prompt itself will also be customizable for displayed info and colors.

Also a "make my PS prompt normal again". 

**Current Status: Successfully running** (Not really functional, just technically runs)

Even more status update: I broke down the code into functions so it's more managable. I've moved the function declaraions to separate PS1 file and called it from `prompt.ps1`. This merely necessitates creating a new symlink (or copying the file itself) to that `$profile` directory mentioned below.    **The Install instructions below are only semi-accurate. Have write something better up tomorrow or the near future.**

### Running the script
Perhaps because of a gap in my PS shell knowledge, I didn't realize I could run `prompt.ps1` directly from the repo directory with

```PowerShell
. .\prompt.ps1
```

For me for instance I would switch my repo directory and run the script:

```PowerShell
cd C:\Users\tildes\Documents\repos\PSSuperPrompt-EC-Edition\scripts
```
**. .\prompt.ps1**



### Requirements (Windows):

- **PS v7.x** for Windows 10/11

I've realized over the course of re-writing and testing there aren't any reall requiments besides PS itself. There is one thing that doesn't work in PS5 which I will probably fix later (ternary variable declaration) ~~This was mistaken text~~

### Optional but good to have:

- *Local admin/root access to system* in order to fully customize prompt (and run programs with local admin) - Note: not fully tested/confirmed as requirement

* **Git for Windows** (available via package manager like chocolatey or [the git website](https://gitforwindows.org/)
  - choco command: 
  **choco install git**


- **[PS module posh-git](https://dahlbyk.github.io/posh-git/)** (recommended by original author)

  - Upon searching I found poshgit listed as a package in the chocolatey repo, but I haven't tried it yet. The command as above would be
  **choco install poshgit**
  - As it turns out there's several ways of installing posh-git that involves a few more steps depending on a number of variables. I'll linking to the instructions on the project's GitHub and leave it at that: 
  https://github.com/dahlbyk/posh-git

- **Chocolatey package manager** for windows: my own preference for Windows package managers (I imagine __win-get__ will server this purpose too)
  
  - Install instructions with a copy/paste installer script can be [found on the chocolatey install guide page](https://chocolatey.org/install).


### Installation [work in progress]

Original line from author for installation:

> To install it, just paste the entire thing into your `$profile`, or dot source the .ps1 file from your `$profile`. Either will work.

I figured out what this means: `$profile` is an environemnt variable pointing to a "special" PS1. Simply open powershell and type in `$profile` to see the path to this PS1 script. Mine for instance is 
`C:\Users\tildes\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

This where my installation steps might differ slightly from yours: I utilized some *symbolic links* to make things easier on myself. I'll provide multiple options for the average non-forking user:

Method 1:
- Go to the equivalent path in your profile: 
`C:\Users\tildes\Documents\PowerShell\`
- copy the prompt.ps1 script from this repo to that folder location
- Rename the script to `Microsoft.PowerShell_profile.ps1` (the file name from your `.$profile` command)
- Open PowerShell and issue the command:`. $profile` 

Method 2, from PowerShell prompt: (optional, more steps and uncessarily complicated)
-  Assuming the above mentioned `$profile` folder does not have any files, create a symblic link for the repository file `PS profile default script.ps1` in that `$profile` folder. 
The command I used was:
```Powershell
 cmd /c mklink C:\Users\tildes\Documents\PowerShell\Microsoft.PowerShell_profile.ps1  "C:\Users\tildes\Documents\repos\PSSuperPrompt-EC-Edition\prompt.ps1"
 ``` 
    
(Ya, I know I'm using the old symbolic link command, don't judge me)
 
- This creates a symbolic link of the `prompt.ps1` script to the script named in your `$profile` command. And you can safely remove said symbolic link any time you want.
- For new version: use same method to create symbolic link to the functions script. something like:

```PowerShell
cmd /c mklink C:\Users\tildes\Documents\PowerShell\superprompt_functions.ps1 C:\Users\tildes\Documents\repos\PSSuperPrompt-EC-Edition\scripts\superprompt_functions.ps1
```

- As above, the final step is to issue `. $profile`

### Uninstall [work in progress]

Since I havne't added a way to drop back to the default PS Prompt yet, merely delete the symbolic links created above and issue `. $profile`.

## Latest Updates will be at the bottom

Re-reading these notes after forking I realized I didn't follow the instructions in my testing of the original version and attempted use. *I may just apply to be a software tester.*

I'll go through the notes here and make some *useful* comments of my own.

The formatting seems to be a little off versus the original but I haven't got around to fixing it. I blame CR/LF.

## Notes

>- Yes, the code is a bit ugly; I've just tweaked with it here and there for a few years and this is what I've come up with, but I've never taken the time to really make it look "spiffy".

 Better looking code than I would do for myself

>- No, it does not have any configurable options. Sorry. Up until literally the moment I'm writing
this, it has always just run on my machines, so configurability for personal preference was
obviously not on my radar. I would love to add that, though, so if I get around to it, or if
someone likes this starting point and wants to shoot me a pull request with extra bells and
whistles, it may very well get those features in the future.

 I'm thinking of planning on thinking of adding some customization options. With a...menu? Or  make the user edit a JSON. Maybe both. 

>- The git functions require the module posh-git to be installed. It tests for this and will work
perfectly fine without it, you just won't get any git details in git repositories. It does use
a global to track that which I added because, at least on my machines, the module test was causing
my prompt to take multiple seconds to draw after every command; this way just tests once so you're
not getting the added delay every time.

 This I wish I'd read again multiple times while I was editing. Would have saved some trouble. Actually explains a couple of things. Although I think I found a better way of testing for the posh-git module. The purpose of the test was different than I thought it was.

>- The Reset-Prompt function (and its alias 'rsp') is really just a way to make mucking with the
prompt easier so I don't have to reload every time I try something, or if I set up another prompt
it lets me switch back to this one with four keystrokes.

As it turns out this reset-prompt functionality was intended for something else entirely, not resetting the PS prompt to the "vanilla" PS prompt.

>- To install it, just paste the entire thing into your `$profile`, or dot source the .ps1 file
from your `$profile`. Either will work.

See above for my "installation" guide. And if you're brave see [@poshcodebear's dev branch for a new install script he's created](https://github.com/poshcodebear/PSSuperPrompt/tree/dev) (I haven't tested with EC edition yet).

>- If I wind up taking the time, at some point I plan to add a better description and do a lot of the
cleanup and configurability stuff I mentioned above.
>   - That said, I know myself too well; please don't hold your breath, as it could happen any time between now and the heat death of the universe, and probably closer to the latter than the former ;)

![](img/thanos-fine-i'll-do-it-myself-ascii-20percent-with-caption.jpg "This only took me a few minutes. Too long.")

Not sure why I made that ascii. Seemed strangely fitting.

> - The job control stuff I just added when I started this repo, and I haven't really used it much at all
since then, so it may or may not be all that great and functional. I just realized that I should be
making better use of jobs, and one of the problems with jobs is how invisible they are (you have to
remember they're there, and they never let you know when they're done), so the jobs piece is meant to
make them more visible.

I understand the intent behind this functionality to some degree now. It's kind of an optional feature. I'll leave it in though.

> - Fun fact: the original inspiration for this prompt is the Gentoo default prompts (both for root and for regular users). It still somewhat resembles that prompt, though obviously heavily modified at this point

You call that fun?

![](img/ectecctrain-ascii-25percent-with-caption.jpg "Well it was fun to make")

Now *this* is fun...or weird. Definitely one of those two.

Also, Gentoo? You just use that so you can take a break while you compile your kernel for the 5th time today, aren't yoU?

I use Arch btw.


---

My interpretation of what this script is apparently doing. Or what this fork _will_ do ultimately. 


---

### Starting Work

This script starts with some extended tests to see if the OS is windows or Linux for purpose of determining if it's being run under an Admin/root level shell. 

After very little work it seems likely some how this OS answer will have to branch out for the two possibilities from the start. In other words ask the OS question and pass that in the main function then take appropriate actions depending on the OS.

Having said that I'm going to re-write it until it works on Windows then go back when I have a Linux environment and add that in. Or via Ubunut-bash-Windows, because of how not convoluted that sounds (running PS 7 via bash via ubuntu via Windows...nailed it. Oh even better: PS 7 via bash via ubuntu via Windows...in a docker container).

I was having trouble with detecting the posh-git module so I did a little experimenting and this actually runs on the PS command line:

```Powershell
if (get-module -Name posh* -ListAvailable -Verbose:$false) { Write-Host "found" } else { Write-Host "not found" }
```
As I'm still troubleshooting without posh-git, this returns *not found* for me. But I could also set a variable to either True or False depending instead. I mean it's a few lines longer to create a function to do this but I know it works.


---

### Announcing Release Candidate 1 (RC1)

As of January 28th 2024 I had successfully gone through and essentially refactored the code: I fixed one or two logic errors, removed or simplified some code and shifted the code in separate functions instead of the one big one (and extra).

Upon running the script for comparison, the custom prompt of the EC edition with that of the original @poshcodebear version, it's maybe 95% there appearance-wise. I still need to test the further functionality of the rest of it. Which I think is just that "jobs" related function. 

The original tested to see if posh-git was installed but didn't do anything further related to git. I think posh-git was supposed to take care of any git-related tasks. Which means EC edition tests to see if `git` runs or not, displays [GIT] and nothing further.

As it turns out the admin privelege test is there for customization of the prompt character (# or $ depending).

Once it appears I've gone as far as I can with re-creating the original in refactored form, I'll start adding features.