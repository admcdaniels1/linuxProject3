#!/bin/bash

#April Crawford and Andrew McDaniels
#delete.sh removes records from a database or spreadsheet based on the supplied
#value for a field
#error codes
#-1 usage
#99 file dne/permissions
#3 improper field usage 5 yard penalty
#5 zero records deleted

#if not enough arguments supplied, print usage message
if [ $# -lt 3 ];then
	echo "Usage: delete.sh <filename> <fieldname> <fieldvalue>"
	exit -1
fi

#get the file extension or exit if it doesn't exist
type=$(./permis.sh $1)
if [ ! "$type" = "db" ] && [ ! "$type" = "ss" ];then
	echo $type
	exit 99
fi

#the field searched for in spreadsheet cannot be total!
if [ "$type" == "ss" ] && [ $2 = "total" ];then
	echo "Error: Cannot delete field $2 in a spreadsheet"
	exit 3
fi

#append the file type to the file name
file="$1.$type"

#we'll need a temporary file to use throughout the script
temp="$(mktemp)"

#count the number of lines in the initial file...
start=$(wc -l $file)
startCount=$(echo $start | cut -d" " -f1)


#REMOVE TOTAL IF SPREADSHEET
#if the file exists and is readable/writeable, check if the field exists
head -1 $file | cut -d: -f2 | grep -w "$2" >> $temp

#if the size of the file is larger than 0, then the field exists and a result
#was appended to the temp file
if [ -s $temp ];then

#if the field exists, get its field number
field=$(awk 'BEGIN{place=1}{
for(i=1;i<=NF;i++){
if($i==a){
place=i;
}}}
END{print place}' a="$2" $temp)

cat $file > $temp

#move to header of the file to the temp file
if [ $type == "db" ];then
	head -1 $temp > $file
	tail +2 $temp | awk '$a!=b' a="$field" b="$3" >> $file
elif [ $type == "ss" ];then
	head -2 $temp > $file
	tail +3 $temp | awk '$a!=b' a="$field" b="$3" >> $file
fi

#remove the temp file, no longer needed!
rm $temp

#count the number of lines in the final file...
end=$(wc -l $file)
endCount=$(echo $end | cut -d" " -f1)
deleted=$((startCount-endCount))
if [ $deleted -eq 0 ];then
	echo "No records available for deletion"
	exit 5
else
	echo "Success: $deleted record(s) were deleted"
fi

#if the size was 0, then print an error message
else
	echo "Error: Field $2 does not exist in $file"
	exit 3
fi
