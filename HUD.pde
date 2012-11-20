class HUD{
  private String[] hudText;  
  private String position;  
  private final PMatrix3D originalMatrix; // for HUD restore                          
  private PApplet p;
  PFont font;
  private int fontSize;
  private final int lineSpace = 10;
  private final int paddingLeft = 5; // spacing between text and rect border
  private final int paddingRight = 10; 
  private final int margin = 10; // spacing between rect border and sketch window
  
  // in mega pixels
  private float currentScreenRes;
  private float STALLION_SCREEN_RES = 3.2768e8; 
  private float MACBOOK_SCREEN_RES = 1.296e6; 
  
  HUD(PApplet applet, String[] _hudText, String _position){
    p = applet;
    hudText = _hudText;
    position = _position;
    originalMatrix = p.getMatrix((PMatrix3D)null);
    currentScreenRes = applet.width*applet.height;
    fontSize = (int) map(currentScreenRes,MACBOOK_SCREEN_RES,STALLION_SCREEN_RES,14,128); // scale font size according to screen resolution   
    font = createFont("Times-Roman", fontSize, false);
  }
                           
  public void draw(){
    hint(DISABLE_DEPTH_TEST);
    cam.beginHUD();
    // hack to add label background
    stroke(255);
    // rect(x,y,width,height)
    if(position.equals("topLeft")) rect(margin, margin, getHudMaxWidth(hudText)+paddingRight, getHudHeight(hudText)); // draw rectangle according to text dimensions
    else if(position.equals("topRight")) rect(p.width-(getHudMaxWidth(hudText)+paddingRight+margin), margin, getHudMaxWidth(hudText)+paddingRight, getHudHeight(hudText));
    else if(position.equals("bottomLeft")) rect(margin, p.height-(getHudHeight(hudText)+margin), getHudMaxWidth(hudText)+paddingRight, getHudHeight(hudText));
    else rect(p.width-(getHudMaxWidth(hudText)+paddingRight+margin), p.height-(getHudHeight(hudText)+margin), getHudMaxWidth(hudText)+paddingRight, getHudHeight(hudText));
    noStroke();
        
    textFont(font);
    if(position.equals("topLeft")) printText(hudText, margin, fontSize+lineSpace);
    else if(position.equals("topRight")) printText(hudText, (int)(p.width-(getHudMaxWidth(hudText)+paddingRight+margin)), fontSize+lineSpace);
    else if(position.equals("bottomLeft")) printText(hudText, margin, (int)(p.height-getHudHeight(hudText)));
    else printText(hudText, (int)(p.width-(getHudMaxWidth(hudText)+paddingRight+margin)), (int)(p.height-getHudHeight(hudText)));
    cam.endHUD();
    hint(ENABLE_DEPTH_TEST);
  }

  private void printText(String[] str, int startX, int startY){
    int currX = startX+paddingLeft;
    int currY = startY;
    for (int i=0; i<str.length; i++) {
      for(int j=0; j<str[i].length(); j++){
        text(str[i].charAt(j),currX,currY);
        // textWidth() spaces the characters out properly.
        currX += textWidth(str[i].charAt(j)); 
      }
      currX = startX+paddingLeft;
      currY += fontSize+lineSpace;
    } 
  }
  
  private float getHudMaxWidth(String[] str){
    float maxWidth = textWidth(str[0]);
    for(int i=1; i<str.length; i++){
      if(textWidth(str[i]) > maxWidth) maxWidth = textWidth(str[i]); 
    }
    return maxWidth;
  }
  
  private float getHudHeight(String[] str){
    return str.length*(fontSize+lineSpace);
  }
}
