class Helix {
  private Job[] jobs;
  private int maxSlots;
  private int[][] colorArray;
  private float helixRadius;
  private float z, deltaZ;
  PShape helix;

  // used for helix movement
  private float rotz = 0;

  Helix(Job[] _jobs, int _maxSlotsPosition, int[][] _colorArray) {
    jobs = _jobs;
    maxSlots = jobs[_maxSlotsPosition].getSlots();
    colorArray = _colorArray;
    helixRadius = 200;
    deltaZ = 2;
  }
  
  public void spin() {
    rotateZ(rotz);
  }

  public void createHelix() {
    helix = createShape(GROUP);
    z = 0;
    float theta = 0;
    for (int i=0; i<jobs.length; i++) {
      if (jobs[i].getState().equals("r")) {  // only use running states. ignore pending (qw) and transitional (dr) states
        color jobColor = colorArray[int(random(colorArray.length))][0];
        String[] parseQueueName = split(jobs[i].getQueueName(), '@');
        float thisSphereRadius = calculateRadius(jobs[i].getSlots(), maxSlots); 
        int nodesPerJob = jobs[i].getSlots()/RANGER_SLOTS_PER_NODE;
      
        for (int j=0; j<nodesPerJob; j++) {
          float cosTheta = cos(theta);
          float sinTheta = sin(theta);  
    
          // convert from polar to cartesian coordinates
          float x = helixRadius * cosTheta;
          float y = helixRadius * sinTheta;
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
          }else theta += asin((thisSphereRadius*2)/helixRadius);
          
        }       
        RUNNING_JOB_COUNT++;
      }   
      rotz += 0.003;
    }
    println("Running Jobs = " + RUNNING_JOB_COUNT);
  }  
  
  private float calculateRadius(int jobSlots, int _maxSlots) {
    float minSlots = 1;   // x0
    float minRadius = 5;  // y0
  
    float maxSlots = _maxSlots; // x1
    float maxRadius = 20;   // y1
  
    // interpolate sphere radius
    return minRadius + (((jobSlots-minSlots)*maxRadius-(jobSlots-minSlots)*minRadius)/(maxSlots-minSlots));
  }
  
  public void setDeltaZ(float _deltaZ){
    this.deltaZ = _deltaZ;
  }
  
  public void setRadius(float _helixRadius){
    this.helixRadius = _helixRadius; 
  }
  
  public void displayHelix(){
    shape(helix); 
  }
}
