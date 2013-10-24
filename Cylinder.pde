// SimpleDateFormat only works in Processing 2.0 with these imports
import java.util.*;
import java.text.*;

class Cylinder {
  private PShape timeRod, cap1, cap2, cap3, bottomRod, topRod;
  private color c;
  private float r, bottomCapZ, h;
  private float ang = 0;
  private int sides = 25;
  private String jobType, jobStartTime;
  private float percentFull;

  Cylinder(color _c, String _jobType, String _jobStartTime, float _r) {
    c = _c;
    r = _r;
    bottomCapZ = r*5;
    jobType = _jobType;
    jobStartTime = _jobStartTime;
    createCylinder();
  }

  private void howMuchToColor() {
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
    dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
    Date currentDate = new Date();
    Date jobStartDate = null;
    try { 
      jobStartDate = dateFormat.parse(jobStartTime);
    } 
    catch(ParseException e) { 
      e.printStackTrace();
    }
    
    long elapsedTime = currentDate.getTime() - jobStartDate.getTime();
    
    // 48 hrs
    if (jobType.equals("normal") || jobType.equals("largemem")) {
      h = 200;
      if(elapsedTime > 1.72e8) percentFull = 1; 
      else percentFull = elapsedTime/1.72e8;    
    } 
    
    // 24 hrs
    else if (jobType.equals("large") || jobType.equals("request") || jobType.equals("normal-mic") || jobType.equals("normal-2mic") || jobType.equals("gpu")) {
      h = 100;
      if(elapsedTime > 8.64e7) percentFull = 1;
      else percentFull = elapsedTime/8.64e7;
    } 
    
    // 12 hrs
    else if (jobType.equals("serial")) {
      h = 60;
      if(elapsedTime > 4.32e7) percentFull = 1;
      else percentFull = elapsedTime/4.32e7;
    } 
    
    // 08 hrs
    else if (jobType.equals("vis")) {
      h = 40;
      if(elapsedTime > 2.88e7) percentFull = 1;      
      else percentFull = elapsedTime/2.88e7;
    } 
    
    // 04 hrs
    else if (jobType.equals("development") || jobType.equals("gpudev") || jobType.equals("visdev")) {
      h = 20;
      if(elapsedTime > 1.44e7) percentFull = 1;
      else percentFull = elapsedTime/1.44e7;  
    }
  }

  private void createCylinder() {
    howMuchToColor(); //determine what portion of the cylinder needs to be colored in
    timeRod = createShape(GROUP);

    /************************************/
    /* Draw colored portion of Cylinder */
    /************************************/

    //cap 1
    cap1 = createShape(); 
    cap1.setFill(c);
    cap1.setStroke(false);
    cap1.beginShape();
    for (int i=0; i<=sides; i++) {
      float  px = cos(ang)*r;
      float  py = sin(ang)*r;
      cap1.vertex(px, py, bottomCapZ); 
      ang+=TWO_PI/sides;
    }
    cap1.endShape(); 
    timeRod.addChild(cap1);

    //body
    bottomRod = createShape();
    bottomRod.setFill(c);
    bottomRod.setStroke(false);
    bottomRod.beginShape(QUAD_STRIP);
    for (int i=0; i<=sides; i++) {
      float  px = cos(ang)*r;
      float  py = sin(ang)*r;
      bottomRod.vertex(px, py, bottomCapZ); 
      bottomRod.vertex(px, py, bottomCapZ+(h*percentFull)); 
      ang+=TWO_PI/sides;
    }
    bottomRod.endShape();
    timeRod.addChild(bottomRod);
    
    //cap2
    cap2 = createShape();
    cap2.setFill(c);
    cap2.setStroke(false);
    cap2.beginShape();
    for (int i=0; i<=sides; i++) {
      float  px = cos(ang)*r;
      float  py = sin(ang)*r;
      cap2.vertex(px, py, bottomCapZ+(h*percentFull)); 
      ang+=TWO_PI/sides;
    }
    cap2.endShape();
    timeRod.addChild(cap2);

    /************************************/
    /* Draw white portion of Cylinder   */
    /************************************/
    
    if(percentFull < 1){
      //body
      topRod = createShape(); 
      topRod.setFill(color(255));
      topRod.setStroke(false);
      topRod.beginShape(QUAD_STRIP);
      for (int i=0; i<=sides; i++) {
        float  px = cos(ang)*r;
        float  py = sin(ang)*r;
        topRod.vertex(px, py, bottomCapZ+(h*percentFull)); 
        topRod.vertex(px, py, bottomCapZ+h); 
        ang+=TWO_PI/sides;
      }
      topRod.endShape(); 
      timeRod.addChild(topRod);
  
      //cap3
      cap3 = createShape(); 
      cap3.setFill(color(255));
      cap3.setStroke(false);
      cap3.beginShape();
      for (int i=0; i<=sides; i++) {
        float  px = cos(ang)*r;
        float  py = sin(ang)*r;
        cap3.vertex(px, py, bottomCapZ+h); 
        ang+=TWO_PI/sides;
      }
      cap3.endShape();
      timeRod.addChild(cap3);
    }
  }
  
  public PShape getCylinder(){
    return timeRod; 
  }
}

