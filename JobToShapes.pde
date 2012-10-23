class JobToShapes {
  Orb o;
  Cylinder c;

  private float orbRadius;
  private float cylinderRadius, cylinderBase;

  JobToShapes(float _orbRadius, String _jobType, String _jobStartTime, color _jobColor) {
    orbRadius = _orbRadius;
    cylinderRadius = orbRadius/5;
    cylinderBase = orbRadius;
    o = new Orb(_jobColor, orbRadius); 
    c = new Cylinder(_jobColor, _jobType, _jobStartTime, cylinderRadius, cylinderBase);
  }

  void display(float theta) {
    pushMatrix();
    rotateY(PI/2);
    rotateX(-theta);
    o.display();
    c.display();
    popMatrix();
  } 

  public float getOrbRadius() {
    return orbRadius;
  } 
}

