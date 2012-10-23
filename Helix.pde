class Helix {
  List<JobToShapes> jobsList = new ArrayList<JobToShapes>();
  private float helixRadius, z;

  // used for helix movement
  private float rotx = PI/3; // arbitrary initial value
  private float roty = -PI/4; // arbitrary initial value
  private float rotz = 0;

  Helix(List<JobToShapes> _jobsList) {
    jobsList = _jobsList;
    helixRadius = 200;
  }
  
  void spin() {
    rotateX(rotx);
    rotateY(roty);
    rotateZ(rotz);
  }

  void display () {
    z = 0;
    float theta = 0;
  
    for (int listCntr=0; listCntr<jobsList.size(); listCntr++) {
      float cosTheta = cos(theta);
      float sinTheta = sin(theta);  

      // convert from polar to cartesian coordinates
      float x = helixRadius * cosTheta;
      float y = helixRadius * sinTheta;
      z += 1.5; 

      pushMatrix();
      translate(x, y, z); 
      jobsList.get(listCntr).display(theta);
      popMatrix();

      // distance between the radii of neighboring spheres dictates theta
      if (listCntr != jobsList.size()-1) theta += asin((jobsList.get(listCntr).getOrbRadius()+jobsList.get(listCntr+1).getOrbRadius())/helixRadius);  
    } 
    rotz += PI/500;
  }  
  
  public float getHelixHeight(){
    return z; 
  }
}
