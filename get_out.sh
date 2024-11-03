# Set cronjob
# same script for root & user [[ -f ~/wait ]] || ~/path/to/get_out.sh


############ Values to configure ########################
user='CHANGEME'

# min/max and step in minutes that the programme will update as the weeks go
minimum_min=30 # To start at 16'30 and has a countdown of 30 min
maximum_min=150 # First week will switch off at 19'00
weekstep_min=15 # Each week will remove 15 from the starting week
first_week=42 # Output of date +%W; today's week number
last_warning=5 # minutes

theme_first="Aurora-Nuevo-Green"
theme_last="Aurora-Nuevo-Red"
log="/home/${user}/goo.log"

########################################################

me=$(whoami)

running=$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager ScheduledShutdown | grep -v poweroff)
run_flag=$?

minute=60
recover=3 # seconds
# If run_flag == 0 it hasn't been set to poweroff before
if [[ ${run_flag} == 0 ]] && [ ! -f ${user}/wait ]; then
    # 10#number makes it base 10 and it works fine on the operation below.
    # https://ubuntuforums.org/showthread.php?t=677751
    nw=$((10#$(date +%W) - first_week))

    # Set minutes changing 15/week
    min=$((maximum_min - (nw - 1) * weekstep_min))
    # set turnout at least 30 minutes! => from 16'30 to 17'00
    (( min > minimum_min )) || min=$minimum_min
    switchoff=$(date +%H:%M -d "+ ${min} min")
    echo " $nw weeks since start and $min to switch off" >> $log

    # Cronjob will run for user and root, the user will control the window, root will shut it down
    if [ $me = "${user}" ]; then
	PID=($(pgrep gnome-session)) # as an array
	if [[ ${#PID} > 0 ]]; then
	    export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/${PID[0]}/environ|cut -d= -f2- | tr -d '\0')
	     theme_default=$(gsettings get org.gnome.desktop.interface gtk-theme)

	    echo " ${#PID} pid found,  DBUS_SESSION_BUS_ADDRESS is ${DBUS_SESSION_BUS_ADDRESS}" >> $log

	    # Change the desktop Adwaita-dark
	    notify-send "You've got ${min} minutes - switching off at ${switchoff}"
	    echo "You've got ${min} minutes - switching off at ${switchoff}" >> $log

	    gsettings set org.gnome.desktop.interface gtk-theme ${theme_first} >> $log  2>&1
	    gsettings set org.gnome.shell.extensions.user-theme name ${theme_first} >> $log  2>&1

	    # Last 5 minutes it becomes red
	    sleep $(( (min - last_warning) * minute ))
	    notify-send "You've got ${last_warning} minutes - switching off at ${switchoff}"
	    echo "You've got ${last_warning} minutes - switching off at ${switchoff}" >> $log
	    gsettings set org.gnome.desktop.interface gtk-theme ${theme_last} >> $log  2>&1
	    gsettings set org.gnome.shell.extensions.user-theme name ${theme_last} >> $log  2>&1

	    # lass 3 seconds => convert all to normal
	    sleep $(( last_warning  * minute - recover ))
	    notify-send "Shutting off"
	    echo "Shutting off" >> $log
	    gsettings reset org.gnome.shell.extensions.user-theme name
	    gsettings set org.gnome.desktop.interface gtk-theme ${theme_default}
	fi
    else
	echo "Switching off in $min" >> $log
	shutdown -h +"$min" >> $log  2>&1
    fi
    echo "Script completing" >> $log
else
    echo "Script cancelled" >> $log
fi
