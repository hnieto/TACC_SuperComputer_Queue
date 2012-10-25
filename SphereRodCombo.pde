class SphereRodCombo {
  
  private float orbRadius;
  private PShape orb;
  private Cylinder rod;

  SphereRodCombo(PShape _orb, Cylinder _rod, float _orbRadius) {
    orbRadius = _orbRadius;
    orb = _orb;
    rod = _rod;
  }

  void display(float theta) {
    pushMatrix();
    rotateY(PI/2);
    rotateX(-theta);
    shape(orb);
    rod.display();
    popMatrix();
  } 

  public float getOrbRadius() {
    return orbRadius;
  } 
}

