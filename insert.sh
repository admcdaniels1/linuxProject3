#!/bin/bash
#Andrew McDaniels & April Crawford
#error codes
#-1 usage
#99 file DNE/permissions
#3 improper field usage

#Usage message
if [ $# -eq "0" ] 
    then
    echo "Usage message: ./insert.sh <database | spreadsheet>"
    exit -1
    fi

#permis searches for files in local directory, returns status of first type of
#database/spreadsheet
status=$(./permis.sh $1)
#if status didn't find a file exit using status from permis
if [ ! "$status" = "db" ] && [ ! "$status" = "ss" ] 
    then
    echo "$status"
    exit 99
    fi

#If its a database 
if [ "$status" = "db" ]
    then
#grabbing the fields
    fields=$(head -1 "$1.db" | cut -d: -f2)
    echo "Enter values for $fields:"
    read input
#Checking number of fields inserted compared to in file
    if [ ! $(echo $input | awk '{print NF}') -eq $(echo $fields | awk '{print NF}') ]
        then
        echo "Different number of fields from original"
        exit 3
        fi
#appending to the end of the database
    echo $input >> "$1.db"
    echo "Record added to \"$(basename $1 .db)\" database."
    exit 0
    fi

#if its a spreadsheet
if [ "$status" = "ss" ] 
    then
    fields=$(head -1 "$1.ss" | cut -d: -f2)
    fields=$(echo "$fields" | sed 's/ total//g')
    echo "Enter values for $fields:"
    read input
    #Checking number of fields inserted compared to in file without a total
    if [ ! $(echo $input | awk '{print NF}') -eq $(echo $fields | awk '{print NF}') ]
        then
        echo "Different number of fields from original"
        exit 3
        fi
#appending to the end of the spreadsheet
    echo $input >> "$1.ss"
    echo "Record added to \"$(basename $1 .ss)\" spreadsheet."
    exit 0
    fi
#just in case
exit 0
