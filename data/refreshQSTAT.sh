#!/bin/sh

# Name: refreshQSTAT.sh
# Description: run " qstat -u '*' " on supercomputers and copy file over to local processing /data folder
# Developer: Heriberto Nieto

processingDataDir=$(pwd)
extension=".xml"

#update via getopts
user=
server=
filename=

usage()
{
cat << EOF

USAGE: ./refreshQSTAT.sh –u user –s server –f filename

This script will run qstat on remote server and return xml file on local machine

OPTIONS:
   -h      Show this message
   -u      Username
   -s      Server hostname
   -f      Filename (xml extension will be added by script)

EOF
}

while getopts “hu:s:f:” OPTION
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
				 f)
						 filename=$OPTARG
						 ;;	
         ?)
             usage
             exit
             ;;
     esac
done

if [[ -z $user ]] || [[ -z $server ]] || [[ -z $filename ]]
	then 
  	usage
    exit 1
fi

echo "Log into $server as $user and update $filename$extension .........."
ssh $user@$server "qstat -u '*' -xml > $filename$extension; ls -l $filename$extension | awk -v "FILE=$filename$extension" '{ print FILE \" updated on \" \$6 \" \" \$7 \" \" \$8 }' " 
echo "#############################################################################################"
printf "\n"

echo "Copy $filename$extension from $server and save as $filename$extension .........."
scp $user@$server:~/$filename$extension $processingDataDir/$filename$extension 
ls -l $processingDataDir/$filename$extension | awk -v "FILE=$filename$extension" '{ print FILE " updated on " $6 " " $7 " " $8 }' 
echo "#############################################################################################"
printf "\n"
