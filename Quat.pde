static class Quat{
  float w, x, y, z;

  Quat() {
    reset();
  }

  Quat(float w, float x, float y, float z) {
    this.w = w;
    this.x = x;
    this.y = y;
    this.z = z;
  }

  final void reset(){
    this.w = 1.0;
    this.x = 0.0;
    this.y = 0.0;
    this.z = 0.0;
  }

  void set(float w, PVector v) {
    this.w = w;
    this.x = v.x;
    this.y = v.y;
    this.z = v.z;
  }

  void copy(Quat q){
    this.w = q.w;
    this.x = q.x;
    this.y = q.y;
    this.z = q.z;
  }

  static Quat mult(Quat q1, Quat q2){
    Quat res = new Quat();
    res.w = q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z;
    res.x = q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y;
    res.y = q1.w * q2.y + q1.y * q2.w + q1.z * q2.x - q1.x * q2.z;
    res.z = q1.w * q2.z + q1.z * q2.w + q1.x * q2.y - q1.y * q2.x;
    return res;
  }

  float[] getValue(){
    // transforming this quat into an angle and an axis vector...   

    float sa = (float) Math.sqrt(1.0 - w * w);
    if (sa < PConstants.EPSILON)
    {
      sa = 1.0;
    }
    return new float[] {
      acos(w) * 2, x / sa, y / sa, z / sa
    };
  }
}
