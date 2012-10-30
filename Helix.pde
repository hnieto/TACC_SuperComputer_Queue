class Helix {
  List<SphereRodCombo> nodes = new ArrayList<SphereRodCombo>();
  private float helixRadius, z;

  // used for helix movement
  private float rotz = 0;

  Helix(List<SphereRodCombo> _nodes) {
    nodes = _nodes;
    helixRadius = 200;
  }
  
  void spin() {
    rotateZ(rotz);
  }

  void display () {
    z = 0;
    float theta = 0;
    for (int listCntr=0; listCntr<nodes.size(); listCntr++) {
      float cosTheta = cos(theta);
      float sinTheta = sin(theta);  

      // convert from polar to cartesian coordinates
      float x = helixRadius * cosTheta;
      float y = helixRadius * sinTheta;
      z += 2; 
      
      pushMatrix();
      translate(x, y, z); 
      nodes.get(listCntr).display(theta);
      popMatrix();
      
      // distance between the radii of neighboring spheres dictates theta
      if (listCntr != nodes.size()-1) theta += asin((nodes.get(listCntr).getOrbRadius()+nodes.get(listCntr+1).getOrbRadius())/helixRadius);  
    } 
    rotz += 0.003;
  }  
}
