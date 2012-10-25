class Job {
  private int jobNum;
  private float jobPrio;
  private String jobName;
  private String jobOwner;
  private String state;  
  private String jobStartTime;
  private String queueName;
  private int slots;
  
  Job(int _jobNum, float _jobPrio, String _jobName, String _jobOwner, String _state, String _jobStartTime, String _queueName, int _slots){
    jobNum = _jobNum;
    jobPrio = _jobPrio;
    jobName = _jobName;
    jobOwner = _jobOwner;
    state = _state;
    jobStartTime = _jobStartTime;
    queueName = _queueName;
    slots = _slots;  
  }
  
  public int getJobNum(){
    return jobNum; 
  }
  
  public float getJobPrio(){
    return jobPrio; 
  }
  
  public String getJobName(){
    return jobName; 
  }
  
  public String getJobOwner(){
    return jobOwner; 
  }

  public String getState(){
    return state; 
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
  

}

