#!/bin/sh

# Name: refreshQSTAT.sh
# Description: run " qstat -u '*' " on supercomputers and copy file over to local processing /data folder
# Developer: Heriberto Nieto

File=rangerQSTAT.xml
longFile=rangerQSTAT-long.xml
shortFile=rangerQSTAT-short.xml
processingDataDir=$(pwd)

# used to create smaller xml
onlyUpdateShortFile=false
linesInHeader=3
linesPerJob=10

#update via getopts
user=
server=
numberOfJobs=

usage()
{
cat << EOF

USAGE: $0 options

This script will run qstat on remote server and return xml file on local machine

OPTIONS:
   -h      Show this message
   -u      Username
   -s      Server hostname
   -o      only update short xml (must only  be used with -j)
   -j	   Number of jobs to use in small xml file

EOF
}

createShortXML()
{
  echo "Make a shorter version of $longFile, $shortFile ($numberOfJobs jobs), for debugging purposes"
  head -n $(($linesInHeader+$(($linesPerJob*$numberOfJobs)))) $processingDataDir/$longFile > $processingDataDir/$shortFile

  # close xml tags
  echo " </queue_info>" >> $processingDataDir/$shortFile
  echo "</job_info>" >> $processingDataDir/$shortFile
  ls -l $processingDataDir/$shortFile | awk -v "FILE=$shortFile" '{ print FILE " updated on " $6 " " $7 " " $8 }'
}

while getopts “hu:s:oj:” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         u)
             user=$OPTARG
             ;;
         s)
             server=$OPTARG
             ;;
	 o) 
	     onlyUpdateShortFile=true
	     ;;
         j)
             numberOfJobs=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

if [[ $onlyUpdateShortFile == false ]] 
then
     if [[ -z $user ]] || [[ -z $server ]] || [[ -z $numberOfJobs ]]
     then 
          usage
          exit 1
     fi
fi

if [[ $onlyUpdateShortFile == true ]] 
then
     if [[ -z $numberOfJobs ]] 
     then
          usage
          exit 1
     
     elif [[ -n $numberOfJobs ]]
     then
	  if [[ -n $user ]] || [[ -n $server ]]
	  then 
	       usage
	       exit 1
	  
 	  elif [[ -z $user ]] && [[ -z $server ]]
	  then
   	       createShortXML 
               exit 1
	  fi
     fi
fi

echo "Log into $server as $user and update $File .........."
ssh $user@$server "qstat -u '*' -xml > $File; ls -l $File | awk -v "FILE=$File" '{ print FILE \" updated on \" \$6 \" \" \$7 \" \" \$8 }' " 
echo "#############################################################################################"
printf "\n"

echo "Copy $File from $server and save as $longFile .........."
scp $user@$server:~/$File $processingDataDir/$longFile 
ls -l $processingDataDir/$longFile | awk -v "FILE=$longFile" '{ print FILE " updated on " $6 " " $7 " " $8 }' 
echo "#############################################################################################"
printf "\n"

createShortXML
