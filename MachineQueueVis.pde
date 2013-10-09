// used for vis interaction (pan, zoom, rotate)
import peasy.*;
PeasyCam cam;
PMatrix3D baseMat; // used for peasycam + HUD + lights fix

int startTime;
int totalTime = 180000; // 3 minute timer

HUD hud1,hud2,hud3;

// separate jobs array into three arrays depending on slot count
ArrayList<Job> smallJobs = new ArrayList<Job>();
ArrayList<Job> mediumJobs = new ArrayList<Job>();
ArrayList<Job> largeJobs = new ArrayList<Job>();

// split jobs into three helixes depending on slot count
Helix smallJobsHelix, mediumJobsHelix, largeJobsHelix;
int helixType = 1; // variable used to determine which helix to draw
float rotz = 0;

// each variable will keep track of which job to highlight in each helix
int highlighter1 = 0; // used with smallJobsHelix
int highlighter2 = 0; // used with mediumJobsHelix
int highlighter3 = 0; // used with largeJobsHelix

int smallJobsUpperBound = 76;
int mediumJobsUpperBound = 300;
int largeJobsUpperBound = 16385;

// use pshape sphere to highlight jobs in draw w/o affecting performance
PShape wireSphere; 
                           
private String[] description = { "MACHINE QUEUE VISUALIZATION",
                                 "1. Each job is represented by a cluster of same-colored spheres", 
                                 "2. Each sphere is a node",
                                 "3. Sphere size is proportional to the number of nodes per job",
                                 "4. Each cylinder represents allocated time", 
                                 "5. Color along cylinder represents time used" };
         
private String[] jobBox = new String[7];
private String[] title = new String[3]; 

boolean FULLSCREEN = false;

void setup() {
  if(FULLSCREEN) size(displayWidth, displayHeight, OPENGL); // run from "Sketch -> Present"
  else size(1100,700,OPENGL);
  baseMat = g.getMatrix(baseMat);
  cam = new PeasyCam(this, 0, 0, 0, 2000);
  cam.setResetOnDoubleClick(false);
  
  // used to highlight selected job
  wireSphere = createShape(SPHERE,1); 
  wireSphere.setFill(false);
  wireSphere.setStroke(color(255,150));
  
  // separate method that can be re-called to restart sketch
  initSketch();
}

void initSketch() {
  parseFile();
  
  // viewing the entire queue at once is cool but not as useful.
  // breaking the queue into three smaller helixes should make it easier
  // for the user to search the visualization for specific jobs
  smallJobsHelix = new Helix(smallJobs, getMaxSlotsPosition(smallJobs)); smallJobsHelix.createHelix();  
  mediumJobsHelix = new Helix(mediumJobs, getMaxSlotsPosition(mediumJobs)); mediumJobsHelix.createHelix();
  largeJobsHelix = new Helix(largeJobs, getMaxSlotsPosition(largeJobs)); largeJobsHelix.createHelix();
   
  initHUDs();
  startTime = millis();
} 

void draw() {
  if (millis()-startTime > totalTime) {
    println("Restarting Sketch");
    smallJobs.clear(); smallJobsHelix = null;
    mediumJobs.clear(); mediumJobsHelix = null;
    largeJobs.clear(); largeJobsHelix = null;
    initSketch();
  } else {
    background(0);
    smooth(8);
  
    // save peasycam matrix and reset original
    pushMatrix();
    g.setMatrix(baseMat);
    ambientLight(40, 40, 40);
    directionalLight(255, 255, 255, -150, 40, -140);
    popMatrix();
    
    //rotateZ(rotz);
    
    switch(helixType) {
      case 1: 
        smallJobsHelix.displayHelix();
        highlightJobNodes(highlighter1, smallJobs, smallJobsHelix);
        updateHUD(smallJobsHelix, smallJobs, highlighter1, "SMALL JOBS (<"+ smallJobsUpperBound +" cores)");
        break;
      case 2: 
        mediumJobsHelix.displayHelix();
        highlightJobNodes(highlighter2, mediumJobs, mediumJobsHelix);
        updateHUD(mediumJobsHelix, mediumJobs, highlighter2, "MEDIUM JOBS (" + smallJobsUpperBound + "-" + (mediumJobsUpperBound-1) + " cores)");
        break;
      case 3: 
        largeJobsHelix.displayHelix();
        highlightJobNodes(highlighter3, largeJobs, largeJobsHelix);
        updateHUD(largeJobsHelix, largeJobs, highlighter3, "LARGE JOBS (>" + (mediumJobsUpperBound-1) + " cores)");
        break;
    }  
    
    hud1.draw();
    hud2.draw();
    hud3.draw();
    
    rotz += .0009;
  } 
} 

void parseFile() {
  // Load an JSON 
  JSONArray json = loadJSONArray("queue.json");

  for (int i=0; i < json.size(); i++ ) {    
    JSONObject job = json.getJSONObject(i); 
    if(job.getJSONArray("State").toString().equals("[\"ipf:running\"]")) { // only process running jobs
      int num = job.getInt("LocalIDFromManager");
      String name = job.getString("Name");
      String owner = job.getString("LocalOwner");
      String startTime = job.getString("StartTime").replaceFirst(".$",""); // make sure to remove trailing 'Z' from startTime 
      String queue = job.getString("Queue");
      int slotNum = job.getInt("RequestedSlots");
  
      // create job in appropriate list depending on slot count
      if(slotNum < smallJobsUpperBound) smallJobs.add(new Job(num, name, owner, startTime, queue, slotNum));
      else if(slotNum > (smallJobsUpperBound-1) && slotNum < mediumJobsUpperBound) mediumJobs.add(new Job(num, name, owner, startTime, queue, slotNum));
      else largeJobs.add(new Job(num, name, owner, startTime, queue, slotNum));
    }
  }
}

void initHUDs(){
  jobBox[0] = "Job #" + (highlighter1+1);
  jobBox[1] = "Job Number: " + smallJobs.get(highlighter1).getJobNum();
  jobBox[2] = "Job Name: " + smallJobs.get(highlighter1).getJobName();
  jobBox[3] = "Job Owner: " + smallJobs.get(highlighter1).getJobOwner();
  jobBox[4] = "Job Start Time: " + smallJobs.get(highlighter1).getStartTime();
  jobBox[5] = "Queue Name: " + smallJobs.get(highlighter1).getQueueName(); 
  jobBox[6] = "Slot Count: " + smallJobs.get(highlighter1).getSlots();
  
  hud1 = new HUD(this,description,"topLeft");
  hud2 = new HUD(this,jobBox,"topRight");
  hud3 = new HUD(this,title,"bottomMiddle");
}

int getMaxSlotsPosition(ArrayList<Job> jobs) {
  if (jobs.size() == 0) return -1;
  else {
    int maxSlots = jobs.get(0).getSlots();
    int maxPos = 0;
    for (int i=1; i<jobs.size(); i++) {
      if (jobs.get(i).getSlots() > maxSlots){
        maxSlots = jobs.get(i).getSlots();
        maxPos = i;
      }
    }
    return maxPos;
  }
}

int getMinSlotsPosition(ArrayList<Job> jobs) {
  if (jobs.size() == 0) return -1;
  else {
    int minSlots = jobs.get(0).getSlots();
    int minPos = 0;
    for (int i=1; i<jobs.size(); i++) {
      if (jobs.get(i).getSlots() < minSlots){
        minSlots = jobs.get(i).getSlots();
        minPos = i;
      }
    }
    return minPos;
  }
}

int selectedJob(ArrayList<Job> jobs, Helix helix) {
  for (int i=0; i<jobs.size(); i++) { 
    float tolerance = 10;
    float sphereRadius = jobs.get(i).getSphereRadius(); 
    float x = jobs.get(i).getX();
    float y = jobs.get(i).getY();
    float z = jobs.get(i).getZ();
    float theta = jobs.get(i).getTheta();
    
    for(int j=0; j<jobs.get(i).getNodeCount(); j++){
      float sphereCenterX = screenX(x,y,z);
      if(mouseX <= (sphereCenterX+tolerance) && mouseX >= (sphereCenterX-tolerance)) {
        float sphereCenterY = screenY(x,y,z);
        if(mouseY <= (sphereCenterY+tolerance) && mouseY >= (sphereCenterY-tolerance)) {
          return i;
        }
      }
    
      // move to next sphere in job
      theta += asin((sphereRadius*2)/helix.getHelixRadius());
      x = helix.getHelixRadius() * cos(theta);
      y = helix.getHelixRadius() * sin(theta);
      z += helix.getDeltaZ(); 
    }
  }
  
  return -1;  
} 

void highlightJobNodes(int index, ArrayList<Job> jobs, Helix helix){
  float x,y;
  float z = jobs.get(index).getZ();
  float theta = jobs.get(index).getTheta();
  for(int i=0; i<jobs.get(index).getNodeCount(); i++){
    x = helix.getHelixRadius()*cos(theta);
    y = helix.getHelixRadius()*sin(theta);
    z += helix.getDeltaZ();
          
    pushMatrix();
    translate(x,y,z);
    scale(jobs.get(index).getSphereRadius()*1.1);
    shape(wireSphere);
    popMatrix();
      
    theta += asin((jobs.get(index).getSphereRadius()*2)/helix.getHelixRadius());
  } 
}

// update HUD with highlighted job's info
void updateHUD(Helix helix, ArrayList<Job> jobs, int jobIndex, String helixDescription){
  jobBox[0] = "Job #" + (jobIndex+1);
  jobBox[1] = "Job Number: " + jobs.get(jobIndex).getJobNum();
  jobBox[2] = "Job Name: " + jobs.get(jobIndex).getJobName();
  jobBox[3] = "Job Owner: " + jobs.get(jobIndex).getJobOwner();
  jobBox[4] = "Job Start Time: " + jobs.get(jobIndex).getStartTime();
  jobBox[5] = "Queue Name: " + jobs.get(jobIndex).getQueueName(); 
  jobBox[6] = "Slot Count: " + jobs.get(jobIndex).getSlots(); 
  
  title[0] = helixDescription + "  "; // added extra space in string to better center text within HUD
  title[1] = "Running Jobs = " + helix.getRunningJobCount();
  title[2] = "Reload data in " + (totalTime - (millis()-startTime))/1000 + " seconds   ";
}

void keyPressed() {
  if (key == CODED){
    if (keyCode == UP) {
      helixType++;
      if(helixType > 3) helixType = 1;
    } else if (keyCode == DOWN) {
      helixType--;
      if(helixType < 1) helixType = 3;
    }  
  } 
}

// SELECTION BY MOUSE
void mousePressed() {
  int pickedJob;
  switch(helixType) {
    case 1: 
      pickedJob = selectedJob(smallJobs, smallJobsHelix);
      highlighter1 = pickedJob < 0 ? highlighter1 : pickedJob;
      break;
    case 2: 
      pickedJob = selectedJob(mediumJobs, mediumJobsHelix);
      highlighter2 = pickedJob < 0 ? highlighter2 : pickedJob;
      break;
    case 3: 
      pickedJob = selectedJob(largeJobs, largeJobsHelix);
      highlighter3 = pickedJob < 0 ? highlighter3 : pickedJob;
      break;
  }      
}
