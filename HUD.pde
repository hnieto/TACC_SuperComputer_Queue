class HUD implements ControlListener {
  private ControlP5 hud;
  private Textlabel hudLabel;
  private float deltaZ = 2;
  
  HUD(PApplet applet){
    hud = new ControlP5(applet);
    hudLabel = hud.addTextlabel("label")
                  .setText("\nUSAGE\n\n"    +
                           "d = visualization description\n\n" + 
                           "l = largest job information\n\n" + 
                           "s = smallest job information\n\n" + 
                           "u = usage\n")
                  .setPosition(10, 10)
                  .setColor(color(255)) // white
                  .setFont(createFont("Lucida Console", 10, false));                   
    hud.setAutoDraw(false);
    
    Slider s = hud.addSlider("deltaZ") 
                  .setPosition(10,height-40)
                  .setWidth(100)
                  .setHeight(30)
                  .setRange(2,10)
                  .setValue(2);
                         
    hud.addListener(this); 
  }

  void keepHudOnTop() {
    hint(DISABLE_DEPTH_TEST);
    cam.beginHUD();
    stroke(255);
    rect(10, 10, 370, 110); // hack to add label background
    rect(10,height-40,100,30);
    noStroke();
    hud.draw();
    cam.endHUD();
    hint(ENABLE_DEPTH_TEST);
  }
  
  public void showJobInfo(Job job, String jobSize){
    hudLabel.setValue("\n" + jobSize + " JOB\n\n"    +
                      "Job Number:     " + job.getJobNum()    + "\n" + 
                      "Job Priority:   " + job.getJobPrio()   + "\n" + 
                      "Job Name:       " + job.getJobName()   + "\n" + 
                      "Job Owner:      " + job.getJobOwner()  + "\n" + 
                      "Job Start Time: " + job.getStartTime() + "\n" + 
                      "Queue Name:     " + job.getQueueName() + "\n" + 
                      "Slot Count:     " + job.getSlots()     + "\n"); 
  }
  
  public void showDescription(){
    hudLabel.setValue("\nMACHINE QUEUE VISUALIZATION\n\n"    +
                      "Each job is represented by a cluster of same-colored spheres\n" + 
                      "Each sphere is a node\n" + 
                      "Each cylinder represents allocated time\n" + 
                      "Color along cylinder represents time used\n" +
                      "Sphere size is proportional to the number of nodes per job\n"); 
  }
  
  public void showUsage(){
    hudLabel.setValue("\nUSAGE\n\n"    +
                      "d = visualization description\n\n" + 
                      "l = largest job information\n\n" + 
                      "s = smallest job information\n\n" + 
                      "u = usage\n"); 
  }
  
  public void controlEvent(ControlEvent theEvent) {
    slider(theEvent.value());
  }  
  
  void slider(float theValue) {
    deltaZ = theValue;
  } 
  
  public float getSliderValue(){
    return deltaZ; 
  }
}

