#!/bin/sh

# Name: refreshQSTAT.sh
# Description: run " qstat -u '*' " on supercomputers and copy file over to local processing /data folder# Developer: Heriberto Nieto

host=ranger.tacc.utexas.edu
user=hnieto
File=rangerQSTAT.xml
longFile=rangerQSTAT-long.xml
shortFile=rangerQSTAT-short.xml
processingDataDir=$(pwd)


echo "Log into $host as $user and update $File .........."
ssh $user@$host "rm $File; qstat -u '*' -xml > $File; stat $File | grep Change | awk -F"." '{ print \$1 }' | awk -v "FILE=$File" '{ print FILE \" updated on \" \$2 \" \" \$3 }' "
echo "###################################################"

echo "\n"
echo "Remove local copy of $longFile .........."
rm $processingDataDir/$longFile

echo "Copy $File from $host and save as $longFile .........."
scp $user@$host:/share/home/02117/$user/$File $processingDataDir/$longFile 
stat $processingDataDir/$longFile | awk -v "FILE=$longFile" -F"\"" '{ print FILE " updated on " $2 }' 
echo "###################################################"

echo "\n" 
echo "Remove local copy of $shortFile"
rm $processingDataDir/$shortFile

echo "Make a shorter version of $longFile, $shortFile, for debugging purposes"
head -n 1003 $processingDataDir/$longFile > $processingDataDir/$shortFile

# close xml tags
echo " </queue_info>" >> $processingDataDir/$shortFile
echo "</job_info>" >> $processingDataDir/$shortFile
stat $processingDataDir/$shortFile | awk -v "FILE=$shortFile" -F"\"" '{ print FILE " updated on " $2 }'
