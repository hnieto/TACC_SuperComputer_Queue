class Helix {
  private final int SLOTS_PER_NODE = 16; // ranger=16, longhorn=16, lonestar=12, stampede=16
  private int runningJobCnt = 0;
  
  private ArrayList<Job> jobs;
  private int maxSlots;
  private float helixRadius;
  private float x,y,z, deltaZ;
  PShape helix;
  
  Helix(ArrayList<Job> _jobs, int _maxSlotsPosition) {
    jobs = _jobs;
    maxSlots = jobs.get(_maxSlotsPosition).getSlots();
    helixRadius = 400;
    deltaZ = 2;
  }

  public void createHelix() {
    helix = createShape(GROUP);
    x = 0; y = 0; z = 0;
    float theta = 0;
    for (int i=0; i<jobs.size(); i++) { 
      color jobColor = color(random(0, 255), random(0, 255), random(0, 255)); // color running jobs
      runningJobCnt++;          
      
      float thisSphereRadius = calculateRadius(jobs.get(i).getSlots(), maxSlots); 
      int nodesPerJob = jobs.get(i).getSlots()/SLOTS_PER_NODE;
      
      if(nodesPerJob == 0) nodesPerJob = 1; // jobs with less than SLOTS_PER_NODE cores get rounded to 1 node
      
      jobs.get(i).setStartCoordinates(x,y,z,theta);
      jobs.get(i).setNodeCount(nodesPerJob);
      jobs.get(i).setSphereRadius(thisSphereRadius);
    
      for (int j=0; j<nodesPerJob; j++) {  
  
        // convert from polar to cartesian coordinates
        x = helixRadius * cos(theta);
        y = helixRadius * sin(theta);
        z += deltaZ; 
                  
        // create cyliner+orb pshape
        PShape cylorb = createShape(GROUP);
        cylorb.translate(x, y, z); 
        cylorb.rotateY(PI/2);
        cylorb.rotateX(-theta);
        
        // create orb pshape
        PShape orb = createShape(SPHERE, thisSphereRadius);
        orb.setStroke(false);
        orb.setFill(jobColor);
        cylorb.addChild(orb);
        
        // create time cylinder
        Cylinder timeCylinder = new Cylinder(jobColor, jobs.get(i).getQueueName(), jobs.get(i).getStartTime(), thisSphereRadius/5);
        cylorb.addChild(timeCylinder.getCylinder()); 
        
        helix.addChild(cylorb);
        
        // distance between the radii of neighboring spheres dictates theta
        if ((j == nodesPerJob-1) && (i != jobs.size()-1)) {
          float nextSphereRadius = calculateRadius(jobs.get(i+1).getSlots(), maxSlots); 
          theta += asin((thisSphereRadius+nextSphereRadius)/helixRadius);  
        }else {
          theta += asin((thisSphereRadius*2)/helixRadius);
        }
      }       
    }
  }  
  
  private float calculateRadius(int jobSlots, int _maxSlots) {
    float minSlots = 1;   // x0
    float minRadius = 5;  // y0
  
    float maxSlots = _maxSlots; // x1
    float maxRadius = 20;   // y1
  
    // interpolate sphere radius
    return minRadius + (((jobSlots-minSlots)*maxRadius-(jobSlots-minSlots)*minRadius)/(maxSlots-minSlots));
  }
  
  public void displayHelix(){
    shape(helix); 
  }
  
  public float getHelixRadius() {
    return helixRadius; 
  }
  
  public float getDeltaZ() {
    return deltaZ; 
  }
  
  public int getRunningJobCount() {
    return runningJobCnt; 
  }
  
}
