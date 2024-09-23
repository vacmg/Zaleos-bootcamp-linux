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

tar cJvf "${backupFile}.tar.xz" "$backupDir" &> "${backupFile}.log"
