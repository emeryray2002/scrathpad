#!/bin/bash

# This is a script to throw a notification whenever a Verodin service uses more than X% CPU


#Set this limit to whatever you want, 1=1%, 100 = 100%
cpulimit=1
#

prefix=${TMPDIR}cron_cpu
current=$(ps -erco %cpu,command | tail -n+2 | sed 's/^ *//' | grep verodin)
echo "$current" > $prefix$(date +%s)
a=($prefix*); for ((i=0;i<=${#a[@]}-3;i++)); do rm "${a[i]}"; done
[[ $(awk '{s+=$1}END{printf "%i",s}' <<< "$current") -lt $cpulimit ]] && exit
averages=$(awk '{cpu=$1;sub(/[^ ]+ /,"");a[$0]+=cpu;c[$0]++}END{for(i in a){printf "%.1f %s\n",a[i]/c[$0],i}}' $prefix* | sort -rn)
if [[ $(awk '{s+=$1}END{printf "%i",s}' <<< "$averages") -ge $cpulimit ]]; then
    terminal-notifier -title "CPU use" -message "$(head -n5 <<< "$averages" | paste -sd / -)"
fi

################################
# Install:
# brew install terminal-notifier
# jam in a crontab for this script
