class SphereRodCombo {

  private float orbRadius;
  private PShape orb;
  private Cylinder rod;
  color c;
  private float orbX, orbY, orbZ;

  SphereRodCombo(color _c, PShape _orb, Cylinder _rod, float _orbRadius) {
    c = _c;
    orbRadius = _orbRadius;
    orb = _orb;
    rod = _rod;
  }

  void display(float theta) {
    pushMatrix();
    rotateY(PI/2);
    rotateX(-theta);
    pushMatrix();
    scale(orbRadius);
    orb.fill(c);
    shape(orb);
    popMatrix();
    rod.display();
    popMatrix();
  } 
  
  public float getOrbRadius() {
    return orbRadius;
  } 

  public void setOrbX(float _orbX) {
    this.orbX = _orbX;
  }
  
  public void setOrbY(float _orbY) {
    this.orbY = _orbY;
  }
  
  public void setOrbZ(float _orbZ) {
    this.orbZ = _orbZ;
  }
  
  public float getOrbX() {
    return orbX;
  } 
  
  public float getOrbY() {
    return orbY;
  } 
  
  public float getOrbZ() {
    return orbZ;
  } 
  
}

