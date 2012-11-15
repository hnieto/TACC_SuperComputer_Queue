import processing.opengl.*;
import controlP5.*;
import peasy.*;

HUD hud1;
PeasyCam cam;
PMatrix3D baseMat; // used for peasycam + HUD + lights fix

int[][] colorArray = new int[0][2]; 
PImage colorImage; 

String PATH = "/Users/eddie/Programming/Processing/MachineQueueVis/data/"; // SPECIFY ABSOLUTE PATH WHEN USING MPE
String XMLFILE = "rangerQSTAT-short.xml"; 
Job[] jobs; // array of Job Objects created from XML
List<SphereRodCombo> src = new ArrayList<SphereRodCombo>(); // each Job object will be converted to a SphereRodCombo object

int RANGER_SLOTS_PER_NODE = 16;
int LONGHORN_SLOTS_PER_NODE = 16;
int STAMPEDE_SLOTS_PER_NODE = 16;
int RUNNING_JOB_COUNT = 0;
int ZOMBIE_JOB_COUNT = 0;

PShape parentOrb;
Helix h1;
float deltaZ = 2;
float helixRadius = 200;

void setup() {
  size(1300, 500, OPENGL); 
  baseMat = g.getMatrix(baseMat);
  frameRate(60);
  cam = new PeasyCam(this, 0, 0, 0, 3300);
  colorImage = loadImage(PATH + "colors.png"); // SPECIFY ABSOLUTE PATH WHEN USING MPE
  createColorArr();
  createParentShapes();
  parseFile();
  createShapesFromFile();  // create sphere+cylinder objects from each Job object acquired from XML
  h1 = new Helix(src); 
  hud1 = new HUD(this);
}

void draw() {
  background(0);

  // save peasycam matrix and reset original
  pushMatrix();
  g.setMatrix(baseMat);
  ambientLight(40, 40, 40);
  directionalLight(255, 255, 255, -150, 40, -140);
  popMatrix();

  h1.spin();
  h1.display();
  h1.setDeltaZ(deltaZ);
  h1.setRadius(helixRadius);
  hud1.keepHudOnTop(); 
//  println(frameRate);
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
      }
      ); //add it
    }
  }
}

void createParentShapes() {
  // save one sphere's geometry in video memory 
  parentOrb = createShape(SPHERE, 1);
  parentOrb.noStroke();
}

void parseFile() {
  // Load an XML document
  XML xml = loadXML(PATH + XMLFILE);

  // Get all the job_list elements
  XML[] jobList = xml.getChild("queue_info").getChildren("job_list");
  jobs = new Job[jobList.length];

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

    jobs[i] = new Job(num, prio, name, owner, currState, startTime, queue, slotNum);
  }
}

void createShapesFromFile() {
  // find the largest slot count in the current qstat xml file
  int currMaxSlots = jobs[getMaxSlotsPosition()].getSlots();

  for (int i=0; i<jobs.length; i++) {  // for each Job Object, create a sphere and rod
    if (jobs[i].getState().equals("r")) {  // only use running states. ignore pending (qw) and transitional (dr) states
      color jobColor = colorArray[int(random(colorArray.length))][0];
      String[] parseQueueName = split(jobs[i].getQueueName(), '@');
      float scaler = calculateRadius(jobs[i].getSlots(), currMaxSlots);
      Cylinder newRod = new Cylinder(jobColor, parseQueueName[0], jobs[i].getStartTime(), scaler/5);

      for (int j=0; j<(jobs[i].getSlots()/RANGER_SLOTS_PER_NODE); j++) {
        src.add(new SphereRodCombo(jobColor, parentOrb, newRod, scaler));
      }   
      RUNNING_JOB_COUNT++;
    }     
    else if (jobs[i].getState().equals("dr")) {  // mark zombie jobs with grey
      color jobColor = color(116, 116, 116); 
      String[] parseQueueName = split(jobs[i].getQueueName(), '@');
      float scaler = calculateRadius(jobs[i].getSlots(), currMaxSlots);
      Cylinder newRod = new Cylinder(jobColor, parseQueueName[0], jobs[i].getStartTime(), scaler/5);

      for (int j=0; j<(jobs[i].getSlots()/RANGER_SLOTS_PER_NODE); j++) {
        src.add(new SphereRodCombo(jobColor, parentOrb, newRod, scaler));
      }   
      ZOMBIE_JOB_COUNT++;
    }
  }  
  println("Running Jobs = " + RUNNING_JOB_COUNT);
  println("Zombie Jobs = " + ZOMBIE_JOB_COUNT + "\n");
}

int getMaxSlotsPosition() {
  if (jobs.length == 0) return -1;
  else {
    int maxSlots = jobs[0].getSlots();
    int maxPos = 0;
    for (int i=1; i<jobs.length; i++) {
      if (jobs[i].getSlots() > maxSlots){
        maxSlots = jobs[i].getSlots();
        maxPos = i;
      }
    }
    return maxPos;
  }
}

int getMinSlotsPosition() {
  if (jobs.length == 0) return -1;
  else {
    int minSlots = jobs[0].getSlots();
    int minPos = 0;
    for (int i=1; i<jobs.length; i++) {
      if (jobs[i].getSlots() < minSlots){
        minSlots = jobs[i].getSlots();
        minPos = i;
      }
    }
    return minPos;
  }
}

float calculateRadius(int jobSlots, int _maxSlots) {
  float minSlots = 1;   // x0
  float minRadius = 5;  // y0

  float maxSlots = _maxSlots; // x1
  float maxRadius = 20;   // y1

  // interpolate sphere radius
  return minRadius + (((jobSlots-minSlots)*maxRadius-(jobSlots-minSlots)*minRadius)/(maxSlots-minSlots));
}

void keyPressed() {
  if(key == CODED){
    if(keyCode == UP){
      if((deltaZ += 0.1) > 10) deltaZ = 10;
    }else if(keyCode == DOWN){
      if((deltaZ -= 0.1) < 2) deltaZ = 2;
    }else if(keyCode == RIGHT){
      if((helixRadius += 10) > 400) helixRadius = 400;
    }else if(keyCode == LEFT){
      if((helixRadius -= 10) < 200) helixRadius = 200;
    }
  } else{
      if (key == 'l') {
        int largestJobPosition = getMaxSlotsPosition();
        hud1.showJobInfo(jobs[largestJobPosition], "LARGEST");
      } else if (key == 's') {
          int smallestJobPosition = getMinSlotsPosition();
          hud1.showJobInfo(jobs[smallestJobPosition], "SMALLEST");
      } else if (key == 'd') {
          hud1.showDescription();
      } 
  }
}
