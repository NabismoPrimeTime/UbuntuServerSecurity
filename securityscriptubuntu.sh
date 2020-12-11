#!/bin/bash

#Brian Hartford
#12-8-2020
#This is a script written to detect unusual login activity, by monitoring log files
#As an added precaution we will create a md5 hash of the log file and store that somewhere
#seperately. We can then check to make sure that the log file wasnt altered by any malware trying to cover its tracks.

log_date=$(date +'%m-%d-%Y')

#Create a directory to store logs if one had not already been created. 
#Echo a message to teh console alerting the user to where the logs are located.

if [ -d "/home/SecLogs/" ]
then
	echo " Logs from this script can be found in /home/SecLogs"
else
	mkdir /home/SecLogs/
	echo "Logs from this script can be found in /home/SecLogs"
fi

#Create a variable that includes the date to name log files 
log_filepath="/home/SecLogs/"$log_date"Log.log"

#Create Log file using above variable
touch $log_filepath

# All output from commands within these brackets will be output to the log file
{
echo Logins and Backups audit
echo "_______________________________________________________________________"
echo "Checking for ssh logins between 12 AM and 6AM"
echo

#Searches log files for ssh logins between midnight and 6AM
awk '/sshd/ {if($3 < "06"){print $0}}' /var/log/auth.log
echo
echo " _____________________________________________________________________"

#Search for fail2ban logs
echo
echo Searching Fail2ban logs
cat /var/log/fail2ban.log
echo

#searching for failed logins
echo "_____________________________________________________________________"
echo Searching for failed logins
lastb -i -w  -s yesterday -t now
echo
echo

# Making a backup copy of logs in a seperate location, running them through md5 hash algo to ensure their integrity

md5sum /var/log/auth.log > /home/SecLogs/backuplog
md5sum -c /home/SecLogs/backuplog
md5sum .bashrc > /home/SecLogs/bashrcbackup
md5sum -c /home/SecLogs/bashrcbackup
} > $log_filepath

