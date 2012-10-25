import processing.opengl.*;

// JAXB is part of Java 6.0, but needs to be imported manually
import javax.xml.bind.*;

// zoom, pan, spin
import peasy.*;

// our class for parsing xml file
// this class is defined in its own tab in the Processing PDE
XMLparse file;

// each Job object will be converted to a SphereRodCombo object
List<SphereRodCombo> src = new ArrayList<SphereRodCombo>();

Helix h1;
PeasyCam cam;

void setup() {
  size(1000, 700, OPENGL); 
  cam = new PeasyCam(this, 0, 0, 0, 9000);
  parseFile();
  createShapesFromFile();  // create sphere+cylinder objects from each Job object acquired from XML
  h1 = new Helix(src);
}

void draw() {
  background(0);
  lights();
  h1.spin();
  h1.display();
} 

void parseFile() {
  // the following 2 lines of code will load the xml file and map its contents
  // to the nested object hierarchy defined in the XMLparse class (see below)
  try {
    // setup object mapper using the XMLparse class
    JAXBContext context = JAXBContext.newInstance(XMLparse.class);
    // parse the XML and return an instance of the XMLparse class
    file = (XMLparse) context.createUnmarshaller().unmarshal(createInput("rangerQSTAT-short.xml"));  // specify full path when using MPE
  } 
  catch(JAXBException e) {
    // if things went wrong...
    println("error parsing xml: ");
    e.printStackTrace();
    // force quit
    System.exit(1);
  }
}

void createShapesFromFile() {
  int RANGER_SLOTS_PER_NODE = 16;
  int LONGHORN_SLOTS_PER_NODE = 16;
  int STAMPEDE_SLOTS_PER_NODE = 16;

  // find the largest slot count in the current qstat xml file
  JobComparator comparator = new JobComparator();
  int currMaxSlots = Collections.max(file.jobs, comparator).slots;

  for (Job j : file.jobs) {  // for each Job Object j in file.jobs, create a sphere and rod
    if (j.state.equals("r")) {  // only use running states. ignore pending (qw) and transitional (dr) states
      color jobColor = color(random(255), random(255), random(255)); 
      String[] parseQueueName = split(j.queue_name, '@'); 

      // create orb for each job
      float newOrbRadius = calculateRadius(j.slots, currMaxSlots);
      PShape newOrb = createShape(SPHERE, newOrbRadius);
      newOrb.noStroke();
      newOrb.fill(jobColor); 

      // create rod
      Cylinder newRod = new Cylinder(jobColor, parseQueueName[0], j.JAT_start_time, newOrbRadius/5, newOrbRadius);

      for (int i=0; i<(j.slots/RANGER_SLOTS_PER_NODE); i++) {
        src.add(new SphereRodCombo(newOrb, newRod, newOrbRadius));
      }
      
    }
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
