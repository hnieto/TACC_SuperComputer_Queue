# MachineQueueVis
MachineQueueVis is a [Processing](http://processing.org/) sketch based off of [Paul Bourke](http://paulbourke.net/miscellaneous/gqstats/)’s HPC queue statistics visualization. It converts the qstat output into pairs of spheres and cylinders arranged in a helical pattern that represents the status of the supercomputer’s queue. Our goal was to develop a visualization that could give systems administrators and users a complete understanding of the queue’s state with nothing more than a quick glance. 

##Setup

### Obtaining qstat output
A bash script named `refreshQSTAT.sh` is included in this sketch’s `/data` folder that will handle the following steps:
* SSH into remote server
*	Run the `qstat` command line utility 
*	Create XML file on remote server from `qstat` output with the following format
 
```
<?xml version='1.0'?>
<job_info  xmlns:xsd="http://gridengine.sunsource.net/source/browse/*checkout*/gridengine/source/dist/util/resources/schemas/qstat/qstat.xsd?revision=1.11">
  <queue_info>
    <job_list state="running">
      <JB_job_number>0123456789</JB_job_number>
      <JAT_prio>0.12345</JAT_prio>
      <JB_name>john_doe</JB_name>
      <JB_owner>jd012345</JB_owner>
      <state>r</state>
      <JAT_start_time>2012-01-01T00:00:01</JAT_start_time>
      <queue_name>normal@hostname.edu</queue_name>
      <slots>1234</slots>
    </job_list>
 </queue_info>
</job_info>
```
     
*	Copy XML file from remote server to local machine running Processing sketch
*	Create a shorter version of the XML file for debugging purposes that is based off of the full XML file returned by “qstat” (visualizing the entire queue can be resource intensive). 


### refreshQSTAT.sh
Run this script to update your XML files. Running with only the `–o` and `–j` flags will resize the short XML file (skips ssh and qstat commands).
```
USAGE1: ./refreshQSTAT.sh –u user –s server –j 50
USAGE2: ./refreshQSTAT.sh –o –j 50

This script will run qstat on remote server and return xml file on local machine

OPTIONS:
   -h      Show this message
   -u      Username
   -s      Server hostname
   -o      only update short xml (must only  be used with -j)
   -j	  Number of jobs to use in small xml file
``` 

This part is optional. The script will generate three XML files, one on the remote server and two on the local machine. If you would like to change these file names, open `refreshQSTAT.sh` with your favorite text editor and modify the following variables:
```
File=remoteQSTAT.xml
longFile=localQSTAT-full.xml
shortFile=localQSTAT-brief.xml
```

### MachineQueueVis.pde
This is the main Processing file. You must update the `PATH` variable with the correct location of the `/data` directory on your local machine. 
```
String PATH = "/Users/Username/Documents/Processing/MachineQueueVis/data/";  
```

Also make sure that the `XMLFILE` variable has the full name of the XML file produced from running the `refreshQSTAT.sh` script.
```
String XMLFILE = "localQSTAT-brief.xml"; 
```

# Running

Once `refreshQSTAT.sh` has been run and you have an updated XML file, open the Processing IDE, locate your sketch, and press “Run.” 


# Issues

If you encounter the following issue, `java.lang.OutOfMemoryError: Java heap space`, just increase the maximum available memory in the Processing IDE Preferences menu. To increase performance speed, all of the helix’s vertex data is uploaded into buffers in video memory during initialization, from where they can be read very quickly by the GPU in order to render the scene. This, however, can be very taxing on your system. This is why I would suggest using the smaller XML file for testing purposes and the full XML file on a system with enough GPU memory to handle large visualizations.