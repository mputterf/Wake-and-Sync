#!/bin/bash

#wol = MAC address of destination nic to wake up
#backupsrv = destination machine
#sourcedir= backup source
wol=
backupsrv=
sourcedir=
username=

#Keep track of month for once a month deletion
currentmonth=$(date +%b)
monthfile="$(dirname "$0")/.monthfile.txt"

#Check for manual override
while getopts ":mw" opt; do
        case "${opt}" in
                w  ) manualoverride="normal";;
                m  ) manualoverride="monthly";;
                \? ) echo "Invalid Argument. Use -w for normal backup or -m for backup and delete." >&2
                                   exit 1;;
        esac
done

function readmonthfile {
        
        while IFS= read -r line; do
                monthread=$line
        done < $monthfile
}

function normalbackup {
	rsync -auvvXP -o  -g  * $username@$backupsrv:$sourcedir
}

function monthlybackup {
	rsync -auvvXP -o  -g --delete-before  * $username@$backupsrv:$sourcedir
}

function checkstatus {
retries=0
if [ ! $alive -eq 0 ]; then
	#try pinging again
	ping -c3 $backupsrv
	alive=$?
	#if this is the first attempt, try again, else quit the script
	if [ $retries -eq 0 ]; then
		retries=$((retries+1))
		#sleeping 5 seconds
		sleep 5
		checkstatus
	else
		#echo exiting script
		exit 0
	fi
fi
}

#read monthfile
if [ -f $monthfile ]; then
        	readmonthfile
        else 
		echo "$currentmonth" | tee $monthfile
                monthread=$(date +%b)
fi

#echo "sending Magic Packet"
wakeonlan $wol

#pause for 60 seconds to give backup server time to boot, and check if it's online
echo "sleeping for 60 seconds"
sleep 60

#echo "pinging server"
ping -c3 $backupsrv
alive=$?

checkstatus

#cding to NAS
cd $sourcedir/
#Manual override
if [ $# -eq 1 ]; then
	if [ $manualoverride = "normal" ]; then
		echo "Beginning normal backup (manual)"
                normalbackup
	elif [ $manualoverride = "monthly" ]; then
        	echo "Beginning monthly backup (manual)"
		monthlybackup
	fi
#automatic
elif [ $# -eq 0 ]; then
	if [ $currentmonth = $monthread ]; then
		echo "Beginning normal backup (automatic)"
		normalbackup
	elif [ $currentmonth != $monthread ]; then
		echo "Beginning monthly backup (automatic)"
		monthlybackup
	fi
fi
#sleeping 20 seconds and write month file
echo "$currentmonth" > "$monthfile"
sleep 20
#check if users are logged in. If not, shutdown.
ssh $username@$backupsrv 'userson=$(who | wc -l 2>&1);
	if [ $userson -gt 0 ]; then
		exit 0;
	else
		/sbin/shutdown -P now;
	fi'
