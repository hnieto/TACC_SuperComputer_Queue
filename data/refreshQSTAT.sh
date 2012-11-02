#!/bin/sh

# Name: refreshQSTAT.sh
# Description: run " qstat -u '*' " on supercomputers and copy file over to local processing /data folder
# Developer: Heriberto Nieto

scriptName=`basename $0`
user=$1
host=ranger.tacc.utexas.edu
File=rangerQSTAT.xml
longFile=rangerQSTAT-long.xml
shortFile=rangerQSTAT-short.xml
processingDataDir=$(pwd)

if [ $# -eq 0 ]
  then
    echo "Usage: ./$scriptName user"
    exit 1
fi

echo "Log into $host as $user and update $File .........."
ssh $user@$host "qstat -u '*' -xml > $File; stat $File | grep Change | awk -F"." '{ print \$1 }' | awk -v "FILE=$File" '{ print FILE \" updated on \" \$2 \" \" \$3 }' "
echo "#############################################################################################\n"

echo "Copy $File from $host and save as $longFile .........."
scp $user@$host:~/$File $processingDataDir/$longFile 
stat -f "%Sm" $processingDataDir/$longFile | awk -v "FILE=$longFile" '{ print FILE " updated on " $0 }' 
echo "#############################################################################################\n"

echo "Make a shorter version of $longFile, $shortFile, for debugging purposes"
head -n 1003 $processingDataDir/$longFile > $processingDataDir/$shortFile

# close xml tags
echo " </queue_info>" >> $processingDataDir/$shortFile
echo "</job_info>" >> $processingDataDir/$shortFile
stat -f "%Sm" $processingDataDir/$shortFile | awk -v "FILE=$shortFile" '{ print FILE " updated on " $0 }'
