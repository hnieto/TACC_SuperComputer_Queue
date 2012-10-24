class Cylinder {
  private color c;
  private float r, bottomCapZ, h;
  private float ang = 0;
  private int pts = 8;
  private String jobType;
  private String jobStartTime;
  private float percentFull;

  Cylinder(color _c, String _jobType, String _jobStartTime, float _r, float _bottomCapZ) {
    c = _c;
    r = _r;
    bottomCapZ = _bottomCapZ;
    jobType = _jobType;
    jobStartTime = _jobStartTime;
  }

  public float getColor() {
    return c;
  }

  public float getRadius() {
    return r;
  }

  public float getBottomCapZ() {
    return bottomCapZ;
  }

  public float getHeight() {
    return h;
  }

  void calculateCylinderProperties() {
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
    Date currentDate = new Date();
    Date jobStartDate = null;
    try { 
      jobStartDate = dateFormat.parse(jobStartTime);
    } 
    catch(ParseException e) { 
      e.printStackTrace();
    }
    
    long elapsedTime = currentDate.getTime() - jobStartDate.getTime();

    if (jobType.equals("normal")) {                  // normal       = 24hrs
      h = 50;
      if(elapsedTime > 8.64e7) percentFull = 1; 
      else percentFull = elapsedTime/8.64e7;
    } 
    else if (jobType.equals("long")) {             // long           = 48hrs
      h = 100;
      if(elapsedTime > 1.72e8) percentFull = 1;
      else percentFull = elapsedTime/1.72e8;
    } 
    else if (jobType.equals("largemem")) {         // large          = 24hrs
      h = 50;
      if(elapsedTime > 8.64e7) percentFull = 1;
      else percentFull = elapsedTime/8.64e7;
    } 
    else if (jobType.equals("development")) {      // development    = 02hrs
      h = 5;
      if(elapsedTime > 7.2e6) percentFull = 1;
      else percentFull = elapsedTime/7.2e6;  
    } 
    else if (jobType.equals("serial")) {           // serial         = 16hrs
      h = 35;
      if(elapsedTime > 5.76e7) percentFull = 1;
      else percentFull = elapsedTime/5.76e7;
    } 
    else if (jobType.equals("vis")) {              // vis            = 24hrs
      h = 50;
      if(elapsedTime > 8.64e7) percentFull = 1;      
      else percentFull = elapsedTime/8.64e7;
    }
  }

  void display() {
    calculateCylinderProperties();

    /* Draw colored portion of Cylinder */
    fill(c);

    //cap 1
    beginShape(POLYGON); 
    for (int i=0; i<=pts; i++) {
      float  px = cos(radians(ang))*r;
      float  py = sin(radians(ang))*r;
      vertex(px, py, bottomCapZ); 
      ang+=360/pts;
    }
    endShape(); 

    //body
    beginShape(QUAD_STRIP); 
    for (int i=0; i<=pts; i++) {
      float  px = cos(radians(ang))*r;
      float  py = sin(radians(ang))*r;
      vertex(px, py, bottomCapZ); 
      vertex(px, py, bottomCapZ+(h*percentFull)); 
      ang+=360/pts;
    }
    endShape(); 

    //cap2
    beginShape(POLYGON); 
    for (int i=0; i<=pts; i++) {
      float  px = cos(radians(ang))*r;
      float  py = sin(radians(ang))*r;
      vertex(px, py, bottomCapZ+(h*percentFull)); 
      ang+=360/pts;
    }
    endShape(); 

    /* Draw white portion of Cylinder only if there is still time left */
    if(percentFull < 1){
      fill(255);
  
      //body
      beginShape(QUAD_STRIP); 
      for (int i=0; i<=pts; i++) {
        float  px = cos(radians(ang))*r;
        float  py = sin(radians(ang))*r;
        vertex(px, py, bottomCapZ+(h*percentFull)); 
        vertex(px, py, bottomCapZ+h); 
        ang+=360/pts;
      }
      endShape(); 
  
      //cap2
      beginShape(POLYGON); 
      for (int i=0; i<=pts; i++) {
        float  px = cos(radians(ang))*r;
        float  py = sin(radians(ang))*r;
        vertex(px, py, bottomCapZ+h); 
        ang+=360/pts;
      }
      endShape();
    }
  }
}

