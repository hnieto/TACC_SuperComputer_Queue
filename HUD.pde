//class HUD implements ControlListener {
class HUD{
  private ControlP5 hud;
  private Textlabel hudLabel1, hudLabel2;
//  private float deltaZ = 2;
  
  HUD(PApplet applet){
    hud = new ControlP5(applet);
    hudLabel1 = hud.addTextlabel("label1")
                   .setText("\nUSAGE\n\n"    +
                           "d          = visualization description\n\n" +
                           "l          = largest job information\n\n" + 
                           "s          = smallest job information\n\n" + 
                           "up/down    = increase/decrease helix length\n\n" +
                           "right/left = increase helix radius\n\n")
                   .setPosition(10, 10)
                   .setColor(color(255)) // white
                   .setFont(createFont("Lucida Console", 10, false));   
  
    hudLabel2 = hud.addTextlabel("label2")
                   .setText("\nMACHINE QUEUE VISUALIZATION\n\n"    +
                            "1. Each job is represented by a cluster of same-colored spheres\n\n" + 
                            "2. Each sphere is a node\n\n" + 
                            "3. Sphere size is proportional to the number of nodes per job\n\n" +
                            "4. Each cylinder represents allocated time\n\n" + 
                            "5. Color along cylinder represents time used\n")
                   .setPosition(width-395, 10)
                   .setColor(color(255)) // white
                   .setFont(createFont("Lucida Console", 10, false));                   
    hud.setAutoDraw(false);
/*    
    Slider s = hud.addSlider("deltaZ") 
                  .setPosition(10,height-40)
                  .setWidth(100)
                  .setHeight(30)
                  .setRange(2,10)
                  .setValue(2); 
                         
    hud.addListener(this); */
  }

  void keepHudOnTop() {
    hint(DISABLE_DEPTH_TEST);
    cam.beginHUD();
    stroke(255);
    rect(10, 10, 270, 130); // hack to add label background
    rect(width-405, 10, 395, 130);
//    rect(10,height-40,100,30);
    noStroke();
    hud.draw();
    cam.endHUD();
    hint(ENABLE_DEPTH_TEST);
  }
  
  public void showJobInfo(Job job, String jobSize){
    hudLabel2.setValue("\n" + jobSize + " JOB\n\n"    +
                       "Job Number:     " + job.getJobNum()    + "\n" + 
                       "Job Priority:   " + job.getJobPrio()   + "\n" + 
                       "Job Name:       " + job.getJobName()   + "\n" + 
                       "Job Owner:      " + job.getJobOwner()  + "\n" + 
                       "Job Start Time: " + job.getStartTime() + "\n" + 
                       "Queue Name:     " + job.getQueueName() + "\n" + 
                       "Slot Count:     " + job.getSlots()     + "\n"); 
  }
  
  public void showDescription(){
    hudLabel2.setValue("\nMACHINE QUEUE VISUALIZATION\n\n"    +
                       "1. Each job is represented by a cluster of same-colored spheres\n\n" + 
                       "2. Each sphere is a node\n\n" + 
                       "3. Sphere size is proportional to the number of nodes per job\n\n" +
                       "4. Each cylinder represents allocated time\n\n" + 
                       "5. Color along cylinder represents time used\n"); 
  }
  
/*  
  public void controlEvent(ControlEvent theEvent) {
    slider(theEvent.value());
  }  
 
  void slider(float theValue) {
    deltaZ = theValue;
  } 
  
  public float getSliderValue(){
    return deltaZ; 
  } */
}

