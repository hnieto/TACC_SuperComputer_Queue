// used for vis interaction (pan, zoom, rotate)
import peasy.*;
PeasyCam cam;
PMatrix3D baseMat; // used for peasycam + HUD + lights fix

String PATH = "/Users/eddie/Programming/Processing/MachineQueueVis/data/"; 
String XMLFILE = "ranger.xml"; 

int[][] colorArray = new int[0][2]; 
PImage colorImage; 

HUD hud1,hud2,hud3,hud4;
int drawHud = 1; // variable used to determine which HUD to draw

// separate jobs array into three arrays depending on slot count
Job[] allJobs, smallJobs, mediumJobs, largeJobs;

// split fullHelix into three helixes depending on slot count
Helix fullHelix, smallJobsHelix, mediumJobsHelix, largeJobsHelix;
int helixType = 1; // variable used to determine which helix to draw
float rotz = 0;

// each variable will keep track of which job to highlight in each helix
int highlighter1 = 0; // used with smallJobsHelix
int highlighter2 = 0; // used with mediumJobsHelix
int highlighter3 = 0; // used with largeJobsHelix
int highlighter4 = 0; // used with fullHelix

int smallJobsUpperBound = 76;
int mediumJobsUpperBound = 300;
int largeJobsUpperBound = 16385;

// use pshape sphere to highlight jobs in draw w/o affecting performance
PShape wireSphere; 

private String[] usage = { "USAGE",
                           "u = usage",
                           "d = visualization description",
                           "left/right arrows = traverse jobs",
                           "up/down arrows = traverse helixes" };
                           
private String[] description = { "MACHINE QUEUE VISUALIZATION",
                                 "1. Each job is represented by a cluster of same-colored spheres", 
                                 "2. Each sphere is a node",
                                 "3. Sphere size is proportional to the number of nodes per job",
                                 "4. Each cylinder represents allocated time", 
                                 "5. Color along cylinder represents time used" };
         
private String[] jobBox = new String[8];
private String[] title = new String[3]; 

/* UNCOMMENT FOR FULLSCREEN */
/*boolean sketchFullScreen() {
  return true;
} */

void setup() {
  //size(displayWidth,displayHeight,OPENGL); // UNCOMMENT FOR FULLSCREEN
  size(1300,500,OPENGL);
  baseMat = g.getMatrix(baseMat);
  
  cam = new PeasyCam(this, 0, 0, 0, 2000);
  colorImage = loadImage(PATH + "colors.png"); // SPECIFY ABSOLUTE PATH WHEN USING MPE
  createColorArr();
  parseFile();
  
  // viewing the entire queue at once is cool but not as useful.
  // breaking the queue into three smaller helixes should make it easier
  // for the user to search the visualization for specific jobs
  splitJobsArr();
  smallJobsHelix = new Helix(smallJobs, getMaxSlotsPosition(smallJobs), colorArray); smallJobsHelix.createHelix();  
  mediumJobsHelix = new Helix(mediumJobs, getMaxSlotsPosition(mediumJobs), colorArray); mediumJobsHelix.createHelix();
  largeJobsHelix = new Helix(largeJobs, getMaxSlotsPosition(largeJobs), colorArray); largeJobsHelix.createHelix();
  // radius of wireframe spheres is calculated incorrectly when i create fulHelix. i'll leave it out for now
  // fullHelix = new Helix(allJobs, getMaxSlotsPosition(allJobs), colorArray); fullHelix.createHelix(); 
  
  initHUDs();
  wireSphere = createShape(SPHERE,1);
}

void draw() {
  background(0);
  smooth(8);

  // save peasycam matrix and reset original
  pushMatrix();
  g.setMatrix(baseMat);
  ambientLight(40, 40, 40);
  directionalLight(255, 255, 255, -150, 40, -140);
  popMatrix();
  
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
/*    case 4:
      fullHelix.displayHelix();
      highlightJobNodes(highlighter4, allJobs, fullHelix);
      updateHUD(allJobsHelix, allJobs, highlighter4, "ALL JOBS");
      break; */
  }  

  hud1.draw();
  hud3.draw();
  hud4.draw();
  switch(drawHud) {
    case 1: 
      hud1.draw();
      break;
    case 2: 
      hud2.draw();
      break;
  }
  rotz += .0009;
} 

void initHUDs(){
  jobBox[0] = "Job #" + (highlighter1+1);
  jobBox[1] = "Job Number: " + smallJobs[highlighter1].getJobNum();
  jobBox[2] = "Job Priority: " + smallJobs[highlighter1].getJobPrio();
  jobBox[3] = "Job Name: " + smallJobs[highlighter1].getJobName();
  jobBox[4] = "Job Owner: " + smallJobs[highlighter1].getJobOwner();
  jobBox[5] = "Job Start Time: " + smallJobs[highlighter1].getStartTime();
  jobBox[6] = "Queue Name: " + smallJobs[highlighter1].getQueueName(); 
  jobBox[7] = "Slot Count: " + smallJobs[highlighter1].getSlots();
  
  hud1 = new HUD(this,usage,"topLeft");
  hud2 = new HUD(this,description,"topLeft");
  hud3 = new HUD(this,jobBox,"topRight");
  hud4 = new HUD(this,title,"bottomMiddle");
}

void createColorArr() {
  //loop through all the pixels of the image
  for (int i = 0; i < colorImage.pixels.length; i++) {
    boolean colorExists = false; //bollean variable that checks if the color already exists in the array

    //loop through the values in the array
    for (int j = 0; j < colorArray.length; j++) {
      if (colorArray[j][0] == colorImage.pixels[i]) {
        int count = colorArray[j][1];
        colorArray[j][1] = count +1;
        colorExists = true; //color already exists in the array
      }
    }

    //if the color hasn't been added to the array
    if (colorExists == false) {
      colorArray = (int[][])append(colorArray, new int[] {
        colorImage.pixels[i], 1
      }); //add it
    }
  }
}

void parseFile() {
  // Load an XML document
  XML xml = loadXML(PATH + XMLFILE);

  // Get all the job_list elements
  XML[] jobList = xml.getChild("queue_info").getChildren("job_list");
  allJobs = new Job[jobList.length];

  for (int i=0; i < jobList.length; i++ ) {
    XML jobNumElem = jobList[i].getChild("JB_job_number"); 
    XML jobPrioElem = jobList[i].getChild("JAT_prio"); 
    XML jobNameElem = jobList[i].getChild("JB_name"); 
    XML jobOwnerElem = jobList[i].getChild("JB_owner");
    XML jobStateElem = jobList[i].getChild("state");
    XML jobStartTimeElem = jobList[i].getChild("JAT_start_time");
    XML jobQueueNameElem = jobList[i].getChild("queue_name");
    XML jobSlotsElem = jobList[i].getChild("slots"); 

    int num = int(jobNumElem.getContent());
    float prio = float(jobPrioElem.getContent());
    String name = jobNameElem.getContent();
    String owner = jobOwnerElem.getContent();
    String currState = jobStateElem.getContent();  
    String startTime = jobStartTimeElem.getContent();
    String queue = jobQueueNameElem.getContent(); 
    int slotNum = int(jobSlotsElem.getContent()); 

    allJobs[i] = new Job(num, prio, name, owner, currState, startTime, queue, slotNum);
  }
}

// calculate how many jobs are using n slots 
// where n falls between bound1 and bound2 
int countJobsWithinRange(int bound1, int bound2){ 
  int count = 0;
  for (int i=0; i<allJobs.length; i++) {
    if(allJobs[i].getSlots() > bound1 && allJobs[i].getSlots() < bound2) count++; 
  }
  return count;
}

// split Job allJobs[] into three arrays depending on slot count.
// this will be used to create three more helixes
void splitJobsArr(){
  smallJobs = new Job[countJobsWithinRange(0,smallJobsUpperBound)]; // 75 cores 
  mediumJobs = new Job[countJobsWithinRange(smallJobsUpperBound-1,mediumJobsUpperBound)]; // 76-299 cores 
  largeJobs = new Job[countJobsWithinRange(mediumJobsUpperBound-1, largeJobsUpperBound)]; // 300-16384 cores = 18-1024 nodes
  
  for (int i=0, j=0, k=0, l=0; i<allJobs.length; i++) {
    if(allJobs[i].getSlots() < smallJobsUpperBound) smallJobs[j++] = allJobs[i];
    else if(allJobs[i].getSlots() > (smallJobsUpperBound-1) && allJobs[i].getSlots() < mediumJobsUpperBound) mediumJobs[k++] = allJobs[i];
    else largeJobs[l++] = allJobs[i];
  }  
}

int getMaxSlotsPosition(Job arr[]) {
  if (arr.length == 0) return -1;
  else {
    int maxSlots = arr[0].getSlots();
    int maxPos = 0;
    for (int i=1; i<arr.length; i++) {
      if (arr[i].getSlots() > maxSlots){
        maxSlots = arr[i].getSlots();
        maxPos = i;
      }
    }
    return maxPos;
  }
}

int getMinSlotsPosition(Job arr[]) {
  if (arr.length == 0) return -1;
  else {
    int minSlots = arr[0].getSlots();
    int minPos = 0;
    for (int i=1; i<arr.length; i++) {
      if (arr[i].getSlots() < minSlots){
        minSlots = arr[i].getSlots();
        minPos = i;
      }
    }
    return minPos;
  }
}

void highlightJobNodes(int index, Job arr[], Helix helix){
  float x,y;
  float z = arr[index].getZ();
  float theta = arr[index].getTheta();
  for(int i=0; i<arr[index].getNodeCount(); i++){
    x = helix.getHelixRadius()*cos(theta);
    y = helix.getHelixRadius()*sin(theta);
    z += helix.getDeltaZ();
          
    pushMatrix();
    translate(x,y,z);
    scale(arr[index].getSphereRadius()*1.1);
    wireSphere.noFill();
    wireSphere.stroke(255,150); // opaque wire sphere
    shape(wireSphere);
    popMatrix();
      
    theta += asin((arr[index].getSphereRadius()*2)/helix.getHelixRadius());
  } 
}

// update HUD with highlighted job's info
void updateHUD(Helix helix, Job arr[], int jobIndex, String helixType){
  jobBox[0] = "Job #" + (jobIndex+1);
  jobBox[1] = "Job Number: " + arr[jobIndex].getJobNum();
  jobBox[2] = "Job Priority: " + arr[jobIndex].getJobPrio();
  jobBox[3] = "Job Name: " + arr[jobIndex].getJobName();
  jobBox[4] = "Job Owner: " + arr[jobIndex].getJobOwner();
  jobBox[5] = "Job Start Time: " + arr[jobIndex].getStartTime();
  jobBox[6] = "Queue Name: " + arr[jobIndex].getQueueName(); 
  jobBox[7] = "Slot Count: " + arr[jobIndex].getSlots(); 
  
  title[0] = helixType + "  "; // added extra space in string to better center text within HUD
  title[1] = "Running Jobs = " + helix.getRunningJobCount();
  title[2] = "Zombie Jobs  = " + helix.getZombieJobCount();
}

void keyPressed() {
  if (key == CODED){
    // traverse jobs
    if (keyCode == LEFT){
      // determine which helix is currently drawn on screen 
      // and highlight previous job accordingly 
      if(helixType == 1) { 
        highlighter1--;
        if(highlighter1 < 0) highlighter1 = smallJobs.length-1;
      } else if(helixType == 2) { 
        highlighter2--;
        if(highlighter2 < 0) highlighter2 = mediumJobs.length-1;
      } else if(helixType == 3) { 
        highlighter3--;
        if(highlighter3 < 0) highlighter3 = largeJobs.length-1;
      }/* else if(helixType == 4) {
        highlighter4++;
        if(highlighter4 < 0) highlighter4 = allJobs.length-1; 
      } */
    }else if (keyCode == RIGHT){
      // determine which helix is currently drawn on screen 
      // and highlight next job accordingly       
      if(helixType == 1) highlighter1 = ++highlighter1 % (smallJobs.length);
      else if(helixType == 2) highlighter2 = ++highlighter2 % (mediumJobs.length);
      else if(helixType == 3) highlighter3 = ++highlighter3 % (largeJobs.length);
      // else if(helixType == 4) highlighter4 = ++highlighter4 % (allJobs.length);
      // traverse helixes
    } else if (keyCode == UP) {
      helixType++;
      if(helixType > 3) helixType = 1;
    } else if (keyCode == DOWN) {
      helixType--;
      if(helixType < 1) helixType = 3;
    }  
  } else {
    // populate top-left HUD with description or usage
    if (key == 'd') drawHud = 2;
    else if (key == 'u') drawHud = 1;
  }
}
