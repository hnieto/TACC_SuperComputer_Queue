#!/bin/sh

# Name: refreshQSTAT.sh
# Description: run " qstat -u '*' " on supercomputers and copy file over to local processing /data folder
# Developer: Heriberto Nieto

remoteFile=rangerQSTAT.xml
localFile=rangerQSTAT-long.xml
smallLocalFile=rangerQSTAT-short.xml
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

USAGE1: ./refreshQSTAT.sh –u user –s server –j 50
USAGE2: ./refreshQSTAT.sh –o –j 50

This script will run qstat on remote server and return xml file on local machine

OPTIONS:
   -h      Show this message
   -u      Username
   -s      Server hostname
   -o      only update small xml (must only  be used with -j)
   -j	   Number of jobs to use in small xml file

EOF
}

createShortXML()
{
  echo "Make a shorter version of $localFile, $smallLocalFile ($numberOfJobs jobs), for debugging purposes"
  head -n $(($linesInHeader+$(($linesPerJob*$numberOfJobs)))) $processingDataDir/$localFile > $processingDataDir/$smallLocalFile

  # close xml tags
  echo " </queue_info>" >> $processingDataDir/$smallLocalFile
  echo "</job_info>" >> $processingDataDir/$smallLocalFile
  ls -l $processingDataDir/$smallLocalFile | awk -v "FILE=$smallLocalFile" '{ print FILE " updated on " $6 " " $7 " " $8 }'
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

echo "Log into $server as $user and update $remoteFile .........."
ssh $user@$server "qstat -u '*' -xml > $remoteFile; ls -l $remoteFile | awk -v "FILE=$remoteFile" '{ print FILE \" updated on \" \$6 \" \" \$7 \" \" \$8 }' " 
echo "#############################################################################################"
printf "\n"

echo "Copy $remoteFile from $server and save as $localFile .........."
scp $user@$server:~/$remoteFile $processingDataDir/$localFile 
ls -l $processingDataDir/$localFile | awk -v "FILE=$localFile" '{ print FILE " updated on " $6 " " $7 " " $8 }' 
echo "#############################################################################################"
printf "\n"

createShortXML
