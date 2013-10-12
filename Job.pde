class Job {
  private int jobNum;
  private String jobName;
  private String jobOwner;
  private String jobStartTime;
  private String queueName;
  private int slots;
  
  private boolean positionAcquired = false;
  private float startX, startY, startZ, theta, radius;
  private int nodeCount;
  
  Job(int _jobNum, String _jobName, String _jobOwner, String _jobStartTime, String _queueName, int _slots){
    jobNum = _jobNum;
    jobName = _jobName;
    jobOwner = _jobOwner;
    jobStartTime = _jobStartTime;
    queueName = _queueName;
    slots = _slots;  
  }
  
  // XML Data
  public int getJobNum(){
    return jobNum; 
  }
  
  public String getJobName(){
    return jobName; 
  }
  
  public String getJobOwner(){
    return jobOwner; 
  }
  
  public String getStartTime(){
    return jobStartTime; 
  }
  
  public String getQueueName(){
    return queueName; 
  }
  
  public int getSlots(){
    return slots; 
  }
  
  // Sphere Coordinates 
  public float getX() {
    return startX;
  }

  public float getY() {
    return startY;
  }

  public float getZ() {
    return startZ;
  }

  public float getTheta() {
    return theta;
  }

  public int getNodeCount() {
    return nodeCount;
  }  
  
  public float getSphereRadius() {
    return radius;
  }
  
  public void setStartCoordinates(float _startX, float _startY, float _startZ, float _theta) {
    if(!positionAcquired) {
      startX = _startX;
      startY = _startY;
      startZ = _startZ;
      theta = _theta;
      positionAcquired = true;
    }
  }
  
  public void setNodeCount(int _nodeCount){
    nodeCount = _nodeCount; 
  }
  
  public void setSphereRadius(float _radius){
    radius = _radius; 
  }
}

