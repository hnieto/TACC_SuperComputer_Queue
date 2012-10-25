class Helix {
  List<SphereRodCombo> nodesList = new ArrayList<SphereRodCombo>();
  private float helixRadius, z;

  // used for helix movement
  private float rotz = 0;

  Helix(List<SphereRodCombo> _nodesList) {
    nodesList = _nodesList;
    helixRadius = 200;
  }
  
  void spin() {
    rotateZ(rotz);
  }

  void display () {
    z = 0;
    float theta = 0;
    for (int listCntr=0; listCntr<nodesList.size(); listCntr++) {
      float cosTheta = cos(theta);
      float sinTheta = sin(theta);  

      // convert from polar to cartesian coordinates
      float x = helixRadius * cosTheta;
      float y = helixRadius * sinTheta;
      z += 2; 
      
      pushMatrix();
      translate(x, y, z); 
      nodesList.get(listCntr).display(theta);
      popMatrix();
      
      // distance between the radii of neighboring spheres dictates theta
      if (listCntr != nodesList.size()-1) theta += asin((nodesList.get(listCntr).getOrbRadius()+nodesList.get(listCntr+1).getOrbRadius())/helixRadius);  
    } 
    rotz += PI/500;
  }  
  
  public float getHelixHeight(){
    return z; 
  }
}
