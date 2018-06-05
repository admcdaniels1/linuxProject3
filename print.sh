#!/bin/bash
#Andrew McDaniels & April Crawford
#We decided against backgrounding evince, since we need to remove all temp
#files. So just background this script instead, and it will deal with cleanup.
#error codes
#-1 usage
# 99 file dne/permissions
# 3 improper field usage

#usage message
if [  "$#" -eq "0" ]
    then
    echo "Usage: ./print.sh <database_name> [-n|-r] [-n|-r] [<field_name>]"
    exit -1
    fi

#Checking which type of database/spreadsheet
status=$(./permis.sh $1)
if [ ! "$status" = "db" ] && [ ! "$status" = "ss" ]
    then
    echo "$status"
    exit 99
    fi


#attempting to build a command st "sort $rever $numer -k$fieldnum $1", is 
#differently based on spreadsheet or database
filename="$1.$status"
rever="" #first optional cli a
numer="" #second optional cli a
fieldnum="" #third optional cli a

#checking command line arguements; hilariously -r -r and -n -n work both with
#this program and with sort. So that will not throw an error. 
if [ "$2" = "-n" ] || [ "$2" = "-r" ]; then numer="$2"; shift "1"; fi
if [ "$2" = "-n" ] || [ "$2" = "-r" ]; then rever="$2"; shift "1"; fi
if [ "$#" -gt "1" ]; then fieldnum="$2"

#grabbing the fields in a database/spreadsheet, setting face to be the field we
#are searching for. Counts for total as well in a spreadsheet, but waits until
#the field total is filled for all values before sorting
    header=$(head -1 $filename | cut -d: -f2)
    face=$(echo "$header" | awk 'BEGIN{sta=0}{
        for(i=1; i<=NF; i++){
            if($i == fn){
                sta=i;
            }}}END{print sta}' fn="$fieldnum" )
#if the awk script didn't find a matching field
    if [ "$face" = "0" ]
        then
        echo "Field to sort on not found. Try again."
        exit 3
        fi
    else
        header=$(head -1 $filename | cut -d: -f2)
         face="1" 
    fi

#if its a database do database things
if [ "$status" = "db" ] 
    then
    temper=$(tail +2 "$filename" | sort $rever $numer "-k$face" )
#using printf here for adding newlines without multiple echo
    printf ".sp 10\n.ps 14\n.vs 16\n.TS\ncenter box tab(/);\n" > tmp.tr
    #keyN=$(echo "$header" | wc -w )
    for word in $header; 
        do
        echo -n "c " >> tmp.tr
        done    
    printf ".\n" >> tmp.tr   
    echo "$header" | sed 's/ /\//g' >> tmp.tr 
    printf ".sp .1v\n_\n.sp .1v\n" >>tmp.tr
    echo "$temper" | sed 's/ /\//g' >> tmp.tr
    echo ".TE" >> tmp.tr
    tbl tmp.tr | groff > tmp.ps
    evince tmp.ps 
    fi

#if its a spreadsheet do other things like waiting to sort until near the end
if [ "$status" = "ss" ]
    then
    temper=$(tail +3 "$filename")
#finding the key for all the weights, also trimming it down to just the second
#line, where the weights are stored
    key=$(head -2 $filename | tail -1 | cut -d: -f2)
    numb=$(tail +3 $filename | awk -F" " '{print NF}' | head -1)
    counter=1
    echo "$key" > tmp.txt
#building a temp file full of weights, for to paste with just the data part of
#a spreadsheet. This makes the awk script work on just one line of code, rather
#than just refrencing something out of view.
    while [ $counter -lt $(echo "$temper" | wc -l ) ]
        do
        echo "$key" >> tmp.txt
        counter=$(($counter+1))
        done
    awker=$(paste <(echo "$temper") tmp.txt)
#multiplying all the lines by the weight, to generate total
   totals=$(echo "$awker" | awk '{
        linesum = 0;
        for(i = 1; i <= numb; i++){
            linesum = linesum + ($i *$(i+numb));
            }
        linesum=linesum/100;
        print linesum
       
    }' numb="$numb")
#pasting the two together, each row with their appropiate total
    new=$(paste -d" " <(echo "$temper") <(echo "$totals"))
    newer=$(echo "$new" | sort $rever $numer "-k$face")
#begin building the .tr file for use. I love magic numbers/strings
    printf ".sp 10\n.ps 14\n.vs 16\n.TS\ncenter box tab(/);\n" > tmp.tr
#building the columns for each field, you need as many as there are fields
    for word in $header;
        do
        echo -n "c " >> tmp.tr
        done
    printf ".\n" >> tmp.tr
    echo "$header" | sed 's/ /\//g' >> tmp.tr
    printf ".sp .1v\n_\n.sp .1v\n" >> tmp.tr
    echo "$newer" | sed 's/ /\//g' >> tmp.tr
    echo ".TE" >> tmp.tr
    tbl tmp.tr | groff > tmp.ps
    evince tmp.ps
    fi
#removing all temp files that were used
rm tmp.tr
rm tmp.ps
if [ -e temp.txt ]; then rm tmp.txt; fi

exit 0

