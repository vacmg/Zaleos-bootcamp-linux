#!/usr/bin/env bash

# Usage: ./backupConfig.sh create backupDir backupFile isPeriodic(1) minute hour dayOfMonth month dayOfWeek
# Usage: ./backupConfig.sh create backupDir backupFile isPeriodic(0) timeArgs...
# Usage: ./backupConfig.sh create backupDir backupFile isPeriodic(0)
# Example: ./backupConfig.sh list
# Example: ./backupConfig.sh remove id

# Example: ./backupConfig.sh /home/user/backupData /home/user/backup.tar.gz 0 now +10min

backupRunnerScriptDir="/home/vm/Documentos/GitHub/Zaleos-bootcamp-linux/proyecto-bash/backupRunner.sh"

function create()
{
    if [ $# -lt 3 ]
    then
        echo "To program a backup to be run according to a specific periodic schedule: ./backupConfig.sh create backupDir backupFile 1 minute hour dayOfMonth month dayOfWeek" >&2
        echo "To program a backup to be run once in the future: ./backupConfig.sh create backupDir backupFile 0 timeArgs..." >&2
        echo "To program a backup to be run now: ./backupConfig.sh create backupDir backupFile 0" >&2
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

    backupCMD="bash $backupRunnerScriptDir $backupDir $backupFile"

    if [ "$isPeriodic" -eq 0 ]
    then
        if [ $# -eq 3 ]
        then
            echo "Backup will be run now" >&2
            at now <<< "$backupCMD"

        else
            timeArgs=${*:4} # get all arguments from the 4th argument
            echo "Backup will be run at $timeArgs" >&2
            at "$timeArgs" <<< "$backupCMD"
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

        if [ ! "$minute" = \* ]
            then
            if [ "$minute" -lt 0 ] || [ "$minute" -gt 59 ]
            then
                echo "Invalid minute value (${minute})" >&2
                exit 1
            fi
        fi

        if [ ! "$hour" = \* ]
            then
            if [ "$hour" -lt 0 ] || [ "$hour" -gt 23 ]
            then
                echo "Invalid hour value (${hour})" >&2
                exit 1
            fi
        fi

        if [ ! "$dayOfMonth" = \* ]
            then
            if [ "$dayOfMonth" -lt 1 ] || [ "$dayOfMonth" -gt 31 ]
            then
                echo "Invalid dayOfMonth value (${dayOfMonth})" >&2
                exit 1
            fi
        fi

        if [ ! "$month" = \* ]
            then
            if [ "$month" -lt 1 ] || [ "$month" -gt 12 ]
            then
                echo "Invalid month value (${month})" >&2
                exit 1
            fi
        fi

        if [ ! "$dayOfWeek" = \* ]
        then
            if [ "$dayOfWeek" -lt 0 ] || [ "$dayOfWeek" -gt 7 ]
            then
                echo "Invalid dayOfWeek value (${dayOfWeek})" >&2
                exit 1
            fi
        fi

        crontab -l 2> /dev/null || ( echo "# crontab of user $USER" | crontab -; echo "No crontab found for user $USER; Creating a new one..." )
        ( crontab -l; echo "$minute $hour $dayOfMonth $month $dayOfWeek $backupCMD" ) | sort -ru | crontab -
        echo "Backup will be run at min=$minute hour=$hour dayOfMonth=$dayOfMonth month=$month dayOfWeek=$dayOfWeek" >&2
    fi
}

if [ "$1" = "create" ]
then
    create "${@:2}"
else
    echo "Invalid mode of operation (${1})" >&2
    echo "Usage: ./backupConfig.sh create/list/remove args" >&2
    exit 1
fi
