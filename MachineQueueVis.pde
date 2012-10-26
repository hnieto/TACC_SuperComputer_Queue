import processing.opengl.*;
import peasy.*;
PeasyCam cam;

String FILE = "rangerQSTAT-long.xml";
Job[] jobs; // array of Job Objects created from XML
List<SphereRodCombo> src = new ArrayList<SphereRodCombo>(); // each Job object will be converted to a SphereRodCombo object

int RANGER_SLOTS_PER_NODE = 16;
int LONGHORN_SLOTS_PER_NODE = 16;
int STAMPEDE_SLOTS_PER_NODE = 16;
int RUNNING_JOB_COUNT = 0;

PShape parentOrb;
Helix h1;

void setup() {
  size(1000, 700, OPENGL); 
  frameRate(60);
  cam = new PeasyCam(this, 0, 0, 0, 3300);
  createParentShapes();
  parseFile();
  createShapesFromFile();  // create sphere+cylinder objects from each Job object acquired from XML
  h1 = new Helix(src);
}

void createParentShapes(){
  // save one sphere's geometry in video memory 
  parentOrb = createShape(SPHERE, 1);
  parentOrb.noStroke();  
}

void parseFile(){
  // Load an XML document
  XML xml = loadXML(FILE);

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
  int currMaxSlots = getMaxSlots();

  for (int i=0; i<jobs.length; i++) {  // for each Job Object, create a sphere and rod
    if (jobs[i].getState().equals("r")) {  // only use running states. ignore pending (qw) and transitional (dr) states
      color jobColor = color(random(255), random(255), random(255)); 
      String[] parseQueueName = split(jobs[i].getQueueName(), '@');
      float scaler = calculateRadius(jobs[i].getSlots(), currMaxSlots);
      
      // create rod
      Cylinder newRod = new Cylinder(jobColor, parseQueueName[0], jobs[i].getStartTime(), scaler/5);

      for (int j=0; j<(jobs[j].getSlots()/RANGER_SLOTS_PER_NODE); j++) {
        src.add(new SphereRodCombo(jobColor, parentOrb, newRod, scaler));
      }      
    }
    RUNNING_JOB_COUNT++;
  }  
  println(RUNNING_JOB_COUNT);
}

int getMaxSlots() {
  if (jobs.length == 0) return -1;
  else {
    int maxSlots = jobs[0].getSlots();
    for (int i=1; i<jobs.length; i++) {
      if (jobs[i].getSlots() > maxSlots) maxSlots = jobs[i].getSlots();
    }
    return maxSlots;
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

void draw() {
  background(0);
  ambientLight(40,40,40);
  directionalLight(255, 255, 255, -150, 40, -140);
  h1.spin();
  h1.display();
  println(frameRate);
} 
