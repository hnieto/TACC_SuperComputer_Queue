class SphereRodCombo {

  private float orbRadius;
  private PShape orb;
  private Cylinder rod;
  private color c;

  SphereRodCombo(color _c, PShape _orb, Cylinder _rod, float _orbRadius) {
    c = _c;
    orbRadius = _orbRadius;
    orb = _orb;
    rod = _rod;
  }

  public void display(float theta) {
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
}

