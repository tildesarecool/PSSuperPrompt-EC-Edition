# PSSuperPrompt

Some cool extra tricks for your PowerShell prompt to display more details and colors

This is a fork of [PSSuperPrompt](https://github.com/poshcodebear/PSSuperPrompt).

Bearing ind mind of course I don't actually know what the purpose of it is or if I'd find it useful. 

I've already worked on it a little bit before the forking. Although re-reading these notes after forking I realize I didn't follow the instructions in my testing and attempted use. *I may just apply to be a software tester.*

I'll go thorugh the notes here and make some *useful* comments of my own.

The formatting seems to be a little off versus the original but I haven't got around to fixing it. I blame CR/LF.

## Notes

>- Yes, the code is a bit ugly; I've just tweaked with it here and there for a few years and this is what I've come up with, but I've never taken the time to really make it look "spiffy".
- Better looking code than I would do for myself

>- No, it does not have any configurable options. Sorry. Up until literally the moment I'm writing
this, it has always just run on my machines, so configurability for personal preference was
obviously not on my radar. I would love to add that, though, so if I get around to it, or if
someone likes this starting point and wants to shoot me a pull request with extra bells and
whistles, it may very well get those features in the future.

- I thinking of planning on thinking of adding some customization options. With a...menu? Or a make the user edit a JSON. Maybe both. 

>- The git functions require the module posh-git to be installed. It tests for this and will work
perfectly fine without it, you just won't get any git details in git repositories. It does use
a global to track that which I added because, at least on my machines, the module test was causing
my prompt to take multiple seconds to draw after every command; this way just tests once so you're
not getting the added delay every time.
- This I wish I'd read again multiple times while I was editing. Would have saved some trouble. Actually explains a couple of things. Although I think I found a better way of testing for the posh-git module. The purpose of the test was different than I thought it was.

>- The Reset-Prompt function (and its alias 'rsp') is really just a way to make mucking with the
prompt easier so I don't have to reload every time I try something, or if I set up another prompt
it lets me switch back to this one with four keystrokes.

Actually I stared at these lines while working on this is it didn't register what these were for. I was about to suggest "a way to reset back to default". Then...well never mind then.

>- To install it, just paste the entire thing into your `$profile`, or dot source the .ps1 file
from your `$profile`. Either will work.

I think I'll move this minor detail to the top of the description and provide more details on what that means and how to do it. As soon as I fugre that out...I'm kidding I'm kidding. I probably know what that means.

>- If I wind up taking the time, at some point I plan to add a better description and do a lot of the
cleanup and configurability stuff I mentioned above.

- That said, I know myself too well; please don't hold your breath, as it could happen any time between now and the heat death of the universe, and probably closer to the latter than the former ;)

![](thanos-fine-i'll-do-it-myself-ascii-20percent-with-caption.jpg "This only took me a few minutes. Too long.")

Not sure why I made that ascii. Seemed strangely fitting.

> - The job control stuff I just added when I started this repo, and I haven't really used it much at all
since then, so it may or may not be all that great and functional. I just realized that I should be
making better use of jobs, and one of the problems with jobs is how invisible they are (you have to
remember they're there, and they never let you know when they're done), so the jobs piece is meant to
make them more visible.

I assume this has to do with running multiple multi-minute long tasks from powershell at the same time. I've never had a real need for such functionality (assuming I'm right about that). I'd sooner open a new tab in Windows Terminal. I don't do lots of compiling or anything either though. I'll leave it in.

> - Fun fact: the original inspiration for this prompt is the Gentoo default prompts (both for root and for regular users). It still somewhat resembles that prompt, though obviously heavily modified at this point

You call that fun?

![](ectecctrain-ascii-25percent-with-caption.jpg "Well it was fun to make")

Now *this* is fun...or weird. Definitely one of those two.

Also, Gentoo? You just use that so you can take a break while you compile your kernel for the 5th time today, aren't yoU?

I use Arch btw.