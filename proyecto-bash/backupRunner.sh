#!/usr/bin/env bash

# Usage: ./backupRunner.sh backupDir backupFile

if [ $# -ne 2 ]
then
    echo "Usage: ./backupRunner.sh backupDir backupFile" >&2
    exit 1
fi

backupDir=$1
backupFile=$2

echo "date: $(date); Backup directory: $backupDir; Backup file: $backupFile" >> "$backupFile"
sleep 50s
