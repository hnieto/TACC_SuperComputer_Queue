class Helix {
  private final int SLOTS_PER_NODE = 12; // ranger=16, longhorn=16, lonestar=12
  private int runningJobCnt = 0;
  private int zombieJobCnt = 0;
  
  private Job[] jobs;
  private int maxSlots;
  private int[][] colorArray;
  private float helixRadius;
  private float x,y,z, deltaZ;
  PShape helix;
  
  Helix(Job[] _jobs, int _maxSlotsPosition, int[][] _colorArray) {
    jobs = _jobs;
    maxSlots = jobs[_maxSlotsPosition].getSlots();
    colorArray = _colorArray;
    helixRadius = 400;
    deltaZ = 2;
  }

  public void createHelix() {
    helix = createShape(GROUP);
    x = 0; y = 0; z = 0;
    float theta = 0;
    for (int i=0; i<jobs.length; i++) {
      if (!jobs[i].getState().equals("qw")) {  // ignore pending (qw)
 
        color jobColor = colorArray[int(random(colorArray.length))][0]; // color running jobs
        if(jobs[i].getState().equals("r")) runningJobCnt++;          
        else if(jobs[i].getState().equals("dr")) { // use gray for zombie jobs
          jobColor = color(116,116,116);
          zombieJobCnt++;
        }
        
        String[] parseQueueName = split(jobs[i].getQueueName(), '@');
        float thisSphereRadius = calculateRadius(jobs[i].getSlots(), maxSlots); 
        int nodesPerJob = jobs[i].getSlots()/SLOTS_PER_NODE;
        
        if(nodesPerJob == 0) nodesPerJob = 1; // jobs with less than SLOTS_PER_NODE cores get rounded to 1 node
        
        jobs[i].setStartCoordinates(x,y,z,theta);
        jobs[i].setNodeCount(nodesPerJob);
        jobs[i].setSphereRadius(thisSphereRadius);
      
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
          orb.noStroke();
          orb.fill(jobColor);
          cylorb.addChild(orb);
          
          // create time cylinder
          Cylinder timeCylinder = new Cylinder(jobColor,parseQueueName[0],jobs[i].getStartTime(),thisSphereRadius/5);
          cylorb.addChild(timeCylinder.getCylinder()); 
          
          helix.addChild(cylorb);
          
          // distance between the radii of neighboring spheres dictates theta
          if ((j == nodesPerJob-1) && (i != jobs.length-1)) {
            float nextSphereRadius = calculateRadius(jobs[i+1].getSlots(), maxSlots); 
            theta += asin((thisSphereRadius+nextSphereRadius)/helixRadius);  
          }else {
            theta += asin((thisSphereRadius*2)/helixRadius);
          }
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
  
  public int getZombieJobCount() {
    return zombieJobCnt;
  }
}
