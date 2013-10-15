// used for vis interaction (pan, zoom, rotate)
import peasy.*;
PeasyCam cam;
PMatrix3D baseMat; // used for peasycam + HUD + lights fix

// used for tuio rotation support
ArcBall arcball; 

HUD hud1,hud2,hud3;

// separate jobs array into three arrays depending on slot count
ArrayList<Job> smallJobs = new ArrayList<Job>();
ArrayList<Job> mediumJobs = new ArrayList<Job>();
ArrayList<Job> largeJobs = new ArrayList<Job>();
ArrayList<Job> allJobs = new ArrayList<Job>();

// split jobs into three helixes depending on slot count
Helix smallJobsHelix, mediumJobsHelix, largeJobsHelix, allJobsHelix;
int helixType = 1; // variable used to determine which helix to draw
float rotz = 0;

// each variable will keep track of which job to highlight in each helix
int highlighter1 = 0; // used with smallJobsHelix
int highlighter2 = 0; // used with mediumJobsHelix
int highlighter3 = 0; // used with largeJobsHelix
int highlighter4 = 0; // used with allJobsHelix

int smallJobsUpperBound = 100;
int mediumJobsUpperBound = 500;
int largeJobsUpperBound = 16385;

// use pshape sphere to highlight jobs in draw w/o affecting performance
PShape wireSphere; 
                           
private String[] description = { "TACC STAMPEDE SUPERCOMPUTER QUEUE",
                                 "1. Each job is represented by a cluster of same-colored spheres", 
                                 "2. Each sphere is a node",
                                 "3. Sphere size is proportional to the number of nodes per job",
                                 "4. Each cylinder represents allocated time", 
                                 "5. Color along cylinder represents time used" };
         
private String[] jobBox = new String[7];
private String[] title = new String[2]; 

boolean FULLSCREEN = false;
boolean USE_TUIO = false;

void setup() {
  if(FULLSCREEN) size(displayWidth, displayHeight, OPENGL); // run from "Sketch -> Present"
  else size(1100,700,OPENGL);
  baseMat = g.getMatrix(baseMat);
  
  if(USE_TUIO) {
    arcball = new ArcBall(width/2, height/2, min(width - 20, height - 20) * 0.8);
    initTUIO(width, height);
  } else {
    // peasycam setup 
    cam = new PeasyCam(this, 0, 0, 0, 2000);
    cam.setResetOnDoubleClick(false);
  }
  
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
  println("smallJobs size = " + smallJobs.size());
  println("mediumJobs size = " + mediumJobs.size());
  println("largeJobs size = " + largeJobs.size());
  println("allJobs size = " + allJobs.size());
  
  smallJobsHelix = new Helix(smallJobs, getMaxSlotsPosition(smallJobs)); smallJobsHelix.createHelix();  
  mediumJobsHelix = new Helix(mediumJobs, getMaxSlotsPosition(mediumJobs)); mediumJobsHelix.createHelix();
  largeJobsHelix = new Helix(largeJobs, getMaxSlotsPosition(largeJobs)); largeJobsHelix.createHelix();
  allJobsHelix = new Helix(allJobs, getMaxSlotsPosition(allJobs)); allJobsHelix.createHelix();
   
  initHUDs();
} 

void draw() {
  if (second() == 30) {
    println("\nRestarting Sketch");
    smallJobs.clear(); 
    smallJobsHelix = null; 
    
    mediumJobs.clear(); 
    mediumJobsHelix = null; 
    
    largeJobs.clear(); 
    largeJobsHelix = null;
    
    allJobs.clear(); 
    allJobsHelix = null;
    
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
    
    if(USE_TUIO) {
      translate(posX, posY);
      scale(zoomScaler);
      arcball.update();
    }
       
    rotateZ(rotz);
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
      case 4: 
        allJobsHelix.displayHelix();
        highlightJobNodes(highlighter4, allJobs, allJobsHelix);
        updateHUD(allJobsHelix, allJobs, highlighter4, "ALL JOBS");
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
      
      // add to allJobs array list
      allJobs.add(new Job(num, name, owner, startTime, queue, slotNum));
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
  title[1] = "Running Jobs = " + helix.getRunningJobCount() + "  ";
}

void keyPressed() {
  if (key == CODED){
    if (keyCode == UP) {  
      if(helixType == 1 && mediumJobs.size() > 0) helixType = 2;
      else if(helixType == 2 && largeJobs.size() > 0) helixType = 3;
      else if(helixType == 3 && allJobs.size() > 0) helixType = 4;
      else if(helixType == 4 && smallJobs.size() > 0) helixType = 1;
    } else if (keyCode == DOWN) {
      if(helixType == 4 && largeJobs.size() > 0) helixType = 3;
      else if(helixType == 3 && mediumJobs.size() > 0) helixType = 2;
      else if(helixType == 2 && smallJobs.size() > 0) helixType = 1;
      else if(helixType == 1 && allJobs.size() > 0) helixType = 4;  
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
    case 4: 
      pickedJob = selectedJob(allJobs, allJobsHelix);
      highlighter4 = pickedJob < 0 ? highlighter4 : pickedJob;
      break;
  }      
}
