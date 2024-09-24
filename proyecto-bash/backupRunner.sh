#!/usr/bin/env bash

# Usage: ./backupRunner.sh backupDir backupFile

if [ $# -ne 2 ]
then
    echo "Usage: ./backupRunner.sh backupDir backupFile" >&2
    echo "Compress backupDir into backupFile.tar.xz" >&2
    exit 1
fi

backupDir=$1
backupFile=$2

backupFileDir=$(dirname "$backupFile")
if [ ! -d "$backupFileDir" ] || [ ! -w "$backupFileDir" ]
then
    echo "Backup file directory does not exist or is not writable" >&2
    exit 1
fi

if [ ! -d "$backupDir" ] || [ ! -r "$backupDir" ]
then
    echo "Backup directory does not exist or is not readable" > "${backupFile}.log"
    exit 1
fi

tar cJvf "${backupFile}.tar.xz" "$backupDir" &>> "${backupFile}.log"
