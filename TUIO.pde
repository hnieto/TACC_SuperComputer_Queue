// we need to import the TUIO library
// and declare a TuioProcessing client variable
import TUIO.*;
TuioProcessing tuioClient;
TuioCursor tuioCursor1 = null;
TuioCursor tuioCursor2 = null;
TuioCursor tuioCursor3 = null;

float startDistance, currDistance;
float prevZoomScaler, zoomScaler = .3;
float startX, startY, posX, posY;

void initTUIO(int w, int h) {
  // we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods (see below)
  tuioClient  = new TuioProcessing(this);
  posX = w/2;
  posY = h/2;
}

float getDistance(TuioCursor tuioCursor1, TuioCursor tuioCursor2) {
  return dist(tuioCursor1.getScreenX(width), tuioCursor1.getScreenY(height), 
              tuioCursor2.getScreenX(width), tuioCursor2.getScreenY(height));
}

// these callback methods are called whenever a TUIO event occurs
// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) { 
  if (tuioCursor1 == null) {
    tuioCursor1 = tcur;
    
    // simulates mouse click which will launch selectedJob() function
    mouseX = tuioCursor1.getScreenX(width);
    mouseY = tuioCursor1.getScreenY(height);
    
    // rotate
    arcball.mousePressed(tuioCursor1.getScreenX(width),tuioCursor1.getScreenY(height));     
  } 
  else if (tuioCursor2 == null) {
    // zoom
    tuioCursor2 = tcur;
    startDistance = getDistance(tuioCursor1, tuioCursor2);
    prevZoomScaler = zoomScaler;      
  }
  else if (tuioCursor3 == null) {
    // pan
    tuioCursor3 = tcur;
    startX = tuioCursor3.getScreenX(width);
    startY = tuioCursor3.getScreenY(height);
  } 
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) { 
  if (tuioCursor1 != null && tuioCursor2 != null && tuioCursor3 != null){
    // pan
    float currX = tuioCursor3.getScreenX(width);
    float currY = tuioCursor3.getScreenY(height);
    float dx = currX - startX;
    float dy = currY - startY;

    posX += dx;
    posY += dy;

    startX = currX;
    startY = currY;  
  }
  else if (tuioCursor1 != null && tuioCursor2 != null) {    
    // zoom
    currDistance = getDistance(tuioCursor1, tuioCursor2);
    zoomScaler = prevZoomScaler*(currDistance/startDistance);
  } 
  else if (tuioCursor1 != null) {
    // rotate
    arcball.mouseDragged(tcur.getScreenX(width),tcur.getScreenY(height));      
  } 
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  if (tuioCursor3 != null && tuioCursor3.getCursorID() == tcur.getCursorID()) {
    // Remove 3nd cursor
    tuioCursor3 = null;
  }
  
  if (tuioCursor2 != null && tuioCursor2.getCursorID() == tcur.getCursorID()) {
    // Remove 2nd cursor
    tuioCursor2 = null;
    // If 3rd cursor still exists, make it the 2nd cursor
    if(tuioCursor3 != null){
      tuioCursor2 = tuioCursor3;
      tuioCursor3 = null; 
      startDistance = getDistance(tuioCursor1, tuioCursor2);
      prevZoomScaler = zoomScaler;
    }
  }

  if (tuioCursor1 != null && tuioCursor1.getCursorID() == tcur.getCursorID()) {
    // Remove 1st cursor
    tuioCursor1 = null;

    // If 2nd still is on object, switch cursors
    if (tuioCursor2 != null) {
      tuioCursor1 = tuioCursor2;
      tuioCursor2 = null;
      arcball.mousePressed(tuioCursor1.getScreenX(width),tuioCursor1.getScreenY(height));    
    }
    // If 3rd cursor still exists, make it the 2nd cursor
    if(tuioCursor3 != null){
      tuioCursor2 = tuioCursor3;
      tuioCursor3 = null; 
      startDistance = getDistance(tuioCursor1, tuioCursor2);
      prevZoomScaler = zoomScaler;
    }
  } 
}

// called after each message bundle representing the end of an image frame
void refresh(TuioTime bundleTime) { 
  redraw();
} 

// NOT NEEDED
public void addTuioObject(TuioObject tobj) {}
public void updateTuioObject(TuioObject tobj) {}  
public void removeTuioObject(TuioObject tobj) {}


