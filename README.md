# GOO! - Get Out of the Office

A small script to help me leaving the office by switching the computer.

Years ago I heard that Nokia used to closed the company at a certain time and everyone had to go home, and they couldn't work beyond those hours because there was nothing to connect to.
It may have been an urban legend as I can't find any reference to that though.

In any case, sometime in 2019 I needed help to leave the office, so I wrote this script to switch off my computer at a particular hour, and every week that time was 15 min earlier.
Then at some point I had to reformat the laptop and I forgot about the script.

Now I'm getting to a similar situation that back then, so I looked into my backups and found it!
And this time, I'm putting it out here for everyone to enjoy!
Maybe it may help others, or may inspire people to write this in a more robust way.

## How does it work?

You configure some values in the script, like the min and max countdown time, the weekly step and your username.
Then set those as a cronjob for your user

```cronjob
30 16 * * 1-5 [[ -f ~/wait ]] || /path/to/get_out_office/get_out.sh
```

and root
```cronjob
30 16 * * 1-5 [[ -f ~youruser/wait ]] || /path/to/get_out_office/get_out.sh
```

When the scripts starts running, the desktop will change to a particular theme (green) and show you a desktop notification about the time you've got left.
This is the first warning, you've got now to start winding down.

Then, when there are 5 minutes left, the desktop will change again (to red) and show you the 5' warning notification. Now you need to save everything and get ready for switch off.

Just 3 seconds before switching off, the whole setup comes to its previous status. And the computer switches off.

>[!warning]
> The script will switch off your computer, you may loss unsaved data.

## Requirements

This only works on Gnome.

- You need to [enable the user-themes extension in the extension menu](https://itsfoss.com/install-switch-themes-gnome-shell/).
- [Download some themes](https://www.gnome-look.org/browse/) into `~/.themes`
- Have a [cron implementation installed](https://wiki.gentoo.org/wiki/Cron) and set it up like the examples above.
- Configure the values in the top of the script.
- Work till your computer shuts down!
