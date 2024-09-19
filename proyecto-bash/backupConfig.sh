#!/usr/bin/env bash

# Usage: ./backupConfig.sh backupDir backupFile isPeriodic(1) minute hour dayOfMonth month dayOfWeek
# Usage: ./backupConfig.sh backupDir backupFile isPeriodic(0) timeArgs...
# Usage: ./backupConfig.sh backupDir backupFile isPeriodic(0)

# Example: ./backupConfig.sh /home/user/backupData /home/user/backup.tar.gz 0 now +10min


if [ $# -lt 3 ]
then
    echo "To program a backup to be run according to a specific periodic schedule: ./backupConfig.sh backupDir backupFile 1 minute hour dayOfMonth month dayOfWeek" >&2
    echo "To program a backup to be run once in the future: ./backupConfig.sh backupDir backupFile 0 timeArgs..." >&2
    echo "To program a backup to be run now: ./backupConfig.sh backupDir backupFile 0" >&2
    exit 1
fi

backupDir=$1
backupFile=$2
isPeriodic=$3

#check if backupDir is a directory and has read permission
if [ -d "$backupDir" ] && [ -r "$backupDir" ]
then
    echo "Backup directory $backupDir exists and is readable" >&2
else
    echo "Backup directory does not exist or is not readable" >&2
    exit 1
fi

#check if backupFile is in a directory and is writable
backupFileDir=$(dirname "$backupFile")
if [ -d "$backupFileDir" ] && [ -w "$backupFileDir" ]
then
    echo "Backup file directory $backupFileDir exists and is writable" >&2
else
    echo "Backup file directory does not exist or is not writable" >&2
    exit 1
fi

if [ "$isPeriodic" -eq 0 ]
then
    if [ $# -eq 3 ]
    then
        echo "Backup will be run now" >&2
        # TODO run at now

    else
        timeArgs=${*:4} # get all arguments from the 4th argument
        echo "Backup will be run at $timeArgs" >&2
        # TODO run at
    fi

else
    if [ $# -ne 8 ]
    then
        echo "To program a backup to be run according to a specific periodic schedule: ./backupConfig.sh backupDir backupFile 1 minute hour dayOfMonth month dayOfWeek" >&2
        exit 1
    fi

    minute=$4
    hour=$5
    dayOfMonth=$6
    month=$7
    dayOfWeek=$8

    if [ "$minute" -lt 0 ] || [ "$minute" -gt 59 ]
    then
        echo "Invalid minute value (${minute})" >&2
        exit 1
    fi

    if [ "$hour" -lt 0 ] || [ "$hour" -gt 23 ]
    then
        echo "Invalid hour value (${hour})" >&2
        exit 1
    fi

    if [ "$dayOfMonth" -lt 1 ] || [ "$dayOfMonth" -gt 31 ]
    then
        echo "Invalid dayOfMonth value (${dayOfMonth})" >&2
        exit 1
    fi

    if [ "$month" -lt 1 ] || [ "$month" -gt 12 ]
    then
        echo "Invalid month value (${month})" >&2
        exit 1
    fi

    if [ "$dayOfWeek" -lt 0 ] || [ "$dayOfWeek" -gt 7 ]
    then
        echo "Invalid dayOfWeek value (${dayOfWeek})" >&2
        exit 1
    fi

    echo "Backup will be run at min=$minute hour=$hour dayOfMonth=$dayOfMonth month=$month dayOfWeek=$dayOfWeek" >&2
    # TODO run cron ( crontab -l; echo "@reboot sleep 10s" ) | crontab -
fi
