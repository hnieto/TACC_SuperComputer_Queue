class Orb {
  private color c;
  private float r; // radius
  
  Orb(color _c, float _r) {
    c = _c;
    r = _r; 
  }
  
  public float getRadius() {
    return r; 
  }
  
  public color getColor() {
    return c; 
  }
  
  public void setRadius(float _r) {
    this.r = _r;
  }
  
  public void setColor(color _c) {
    this.c = _c; 
  }
  
  void display() {
    fill(c);
    noStroke();
    sphereDetail(6);
    sphere(r);
  }
}


