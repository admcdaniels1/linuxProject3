#!/bin/bash
#what happens if both a ss and a database exist in the directory
status=""
if [ -e "$1.db" ]
    then
    status="db"
    fi
#if there exists a $1.db then there probably won't be a $1.db.ss
if [ -e "$1.ss" ]
    then
    status="ss"
    fi
if [ $status = "" ]
    then
    echo "File not found."
    exit 2
    fi
if [ ! -r "$1.$status" ]
    then
    echo "The file $1 is not readable."
    exit 2
    fi
if [ ! -w "$1.$status" ]
    then
    echo "The file $1 is not writable."
    exit 2
    fi
echo "$status"
exit 0
