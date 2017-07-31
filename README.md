# TACC SuperComputer Queue Visualization

![Stampede SuperComputer Queue](http://imgur.com/pqDclOz.png)

This is a [Processing](http://processing.org/) (Java-based) application based off of [Paul Bourke](http://paulbourke.net/miscellaneous/gqstats/)’s HPC queue statistics visualization. It converts the CommnQ server output into pairs of spheres and cylinders arranged in a helical pattern that represents the status of the supercomputer’s queue. Our goal was to develop a visualization that could give systems administrators and users a complete understanding of the queue’s state with nothing more than a quick glance.

In our implementation,
* Each job is represented by a cluster of same-colored, consecutive spheres
* Each sphere is a node
* Sphere size is proportional to the number of nodes per job
* Each cylinder represents allocated time 
* Color along cylinder represents time used

##Setup

### Additional libraries
Download the following libraries (unzip them if necessary) and place them in the `/libraries` Processing directory. For additional information on how to install contributed libraries see [here](http://wiki.processing.org/w/How_to_Install_a_Contributed_Library).
* [PeasyCam](http://mrfeinberg.com/peasycam/)
* [TUIO](http://www.tuio.org/?processing)
* [CommnQ.js](https://bitbucket.org/taccaci/commnq-js)


### Obtaining HPC Queue statistics   
A CommnQ server will return a JSON file with the queue information for TACC's [Stampede](http://www.tacc.utexas.edu/stampede/) Supercomputer every minute. See [Matthew Hanlon's Github Repo](https://bitbucket.org/taccaci/commnq-js) for instructions on how to setup a server and handler.   

#### app.js  

```
'use strict';

var config = require('./config/config')
  , Commnq = require('./lib/commnq')
  , MyQueueHandler = require('./lib/handlers/my-queue-handler');

var server = new Commnq(config.amqp).connect(function() {
  console.log('Commnq ready!');

  // process glue2.activities message to individual host files
  server.registerHandler(new MyQueueHandler({
    outputPath: '/Users/User/Programming/Processing/TACC_SuperComputer_Queue/data/queue.json'
    , routingKey: 'stampede.tacc.xsede.org'
  }));

});
```  

#### my-queue-handler.js   

```
'use strict';

var TaccUtil = require('../tacc-util')
  , FileHandler = require('./file-handler')
  , logger = require('../logger')
  , util = require('util')
  , fs = require('fs-extra')
  , _ = require('underscore');

var MyQueueHandler = function(options) {
  if (! (this instanceof MyQueueHandler)) {
    return new MyQueueHandler(options);
  }

  options.exchange = options.exchange || 'glue2.activities';
  if (options.exchange !== 'glue2.activities') {
    throw new Error('MyQueueHandler is only compatible with the glue2.activities exchange.');
  }

  FileHandler.call(this, options);
};

util.inherits(MyQueueHandler, FileHandler);

/**
* Rewrite the message to smaller, nicer json
*/
MyQueueHandler.prototype.beforeProcessMessage = function(message, deliveryInfo) {
  var hostname = TaccUtil.fixHostname(deliveryInfo.routingKey);
  var data = { 
    hostname: hostname,
    queue: message.ComputingActivity
  };  

  return data;
};

MyQueueHandler.prototype.preprocessOutput = function(outputPath, message) {
  return message.queue;
};

module.exports = MyQueueHandler;
```

#### JSON File
The JSON file returned must be named `queue.json`, stored in the `/data` directory of your sketch,  and have the following format:
 
```
[
  {
    "Queue": "normal",
    "Name": "screen",
    "Extension": {
      "Priority": 3024
    },    
    "UserDomain": "abcd123",
    "CreationTime": "2013-10-14T18:52:07Z",
    "Share": "urn:glue2:ComputingShare:normal.stampede.tacc.xsede.org",
    "ComputingManagerSubmissionTime": "2013-10-14T18:22:12Z",
    "RequestedTotalWallTime": 7372800,
    "LocalOwner": "user",
    "LocalIDFromManager": "1912039",
    "State": [
      "ipf:running"
    ],    
    "ComputingManagerEndTime": "2013-10-14T22:22:12Z",
    "StartTime": "2013-10-14T18:22:12Z",
    "SubmissionTime": "2013-10-14T18:22:12Z",
    "Owner": "unknown",
    "RequestedSlots": 512,
    "EndTime": "2013-10-14T22:22:12Z",
    "ID": "urn:glue2:ComputingActivity:123456789.stampede.tacc.xsede.org",
    "UsedTotalWallTime": 918528
  }
]
```
     

# How To Run  

* Start CommnQ server by running `node app.js` from within the root directory of the downloaded commonq-js folder
* Start Processing sketch


# Interaction  
Since viewing the entire job queue at once might be overwhelming, the sketch splits the queue into 3 smaller helixes. You can traverse them by using the up/down keyboard keys. You can also obtain specific job information by clicking (or touching) a set of spheres. If you have a multitouch system from which to run this sketch, make sure to set the `USE_TUIO` flag to `TRUE` to take advantage of the available multitouch gestures:  
* single-finger camera rotation
* pinch zoom
* three-finger panning  

Otherwise, the `PeasyCam` library will be used for camera control. 
  

# Issues

If you encounter the following issue, `java.lang.OutOfMemoryError: Java heap space`, just increase the maximum available memory in the Processing IDE Preferences menu. To increase performance speed, all of the helix’s vertex data is uploaded into buffers in video memory during initialization, from where they can be read very quickly by the GPU in order to render the scene. This, however, can be very taxing on your system. 
