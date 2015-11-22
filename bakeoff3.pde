import java.util.ArrayList;
import java.util.Collections;

import java.util.ArrayList;
import java.util.Collections;



  



    int index = 0;

    //your input code should modify these!!
    float screenTransX = 0;
    float screenTransY = 0;
    float screenRotation = 0;
    float screenZ = 500f;

    int trialCount = 10; //this will be set higher for the bakeoff

    float border = 0; //have some padding from the sides
    int trialIndex = 0;
    int errorCount = 0;  
    int quadtTime = 0; // time quadts when the first click is captured
    int finishTime = 0; //records the time of the final click
    boolean userDone = false;

    boolean firstClick = true;

    float radius = 40f;

    boolean isNewTrial = true;

    //final int screenPPI = 326; //what is the DPI of the screen you are using?
    final int screenPPI = 449;
    //Many phones listed here: https://en.wikipedia.org/wiki/Comparison_of_high-definition_smartphone_displays


    int prevMouseX = -1;
    int prevMouseY = -1;

    PShape quad;
    PVector v1;
    PVector v2;
    PVector v3;
    PVector v4;

    private class Target
    {
      float x = 0;
      float y = 0;
      float rotation = 0;
      float z = 0;
    }

    ArrayList<Target> targets = new ArrayList<Target>();

    public float inchesToPixels(float inch)
    {
      return inch*screenPPI;
    }

    public void setup() {
      //size((int)inchesToPixels(2f), (int)inchesToPixels(3.5f)); //2x3.5' area -- don't modify this

      size(652, 1141, P2D);

      width = 652;
      height = 1141;

      frameRate(150);
      rectMode(CENTER);
      textFont(createFont("Arial", inchesToPixels(.3f))); //sets the font to Arial that is .3" tall
      textAlign(CENTER);

      border = inchesToPixels(.2f); //padding of 0.2 inches //don't change this! 

      for (int i=0;i<trialCount;i++)  //don't change this!
      {
        Target t = new Target();
        t.x = random(-width/2+border, width/2-border); //set a random x with some padding
        t.y = random(-height/2+border, height/2-border);//set a random y with some padding
        t.rotation = random(0, 360); //random rotation between 0 and 360
        t.z = ((i%20)+1)*inchesToPixels(.15f); //increasing size from .15 up to threshold"
        targets.add(t);
        println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
      }

      Collections.shuffle(targets); // randomize the order of the button;

    }

    public void draw() {

      background(80); //background is light grey
      //background(255,255,255);
      fill(200);
      noStroke();

      /*
        if (quadtTime == 0)
          quadtTime = millis();
       */
      if (userDone)
      {
        text("User completed " + trialCount + " trials", width/2, inchesToPixels(.2f));
        text("User had " + errorCount + " error(s)", width/2, inchesToPixels(.2f)*2);
        text("User took " + (finishTime-quadtTime)/1000f/trialCount + " sec per target", width/2, inchesToPixels(.2f)*3);

        return;
      }

      //===========DRAW TARGET SQUARE=================

      if(isNewTrial)
      {
        pushMatrix();
        translate(width/2,height/2); //center the drawing coordinates to the center of the screen

        Target t = targets.get(trialIndex);


        translate(t.x,t.y); //center the drawing coordinates to the center of the screen
        translate(screenTransX,screenTransY); //center the drawing coordinates to the center of the screen

        rotate(radians(t.rotation));

        // fill(255,0,0); //set color to semi translucent
        //fill(0,255,0);
        //rect(0,0,t.z,t.z);

        /*

          v1 = new PVector(modelX(0, 0, 0), modelY(0, 0, 0));
          v2 = new PVector(modelX(t.z, 0, 0), modelY(t.z, 0, 0));
          v3 = new PVector(modelX(t.z, t.z, 0), modelY(t.z, t.z, 0));
          v4 = new PVector(modelX(0, t.z, 0),modelY(0, t.z, 0));
         */

        v1 = new PVector(modelX(-t.z/2, -t.z/2, 0), modelY(-t.z/2, -t.z/2, 0));
        v2 = new PVector(modelX(t.z/2, -t.z/2, 0), modelY(t.z/2,-t.z/2, 0));
        v3 = new PVector(modelX(t.z/2, t.z/2, 0), modelY(t.z/2, t.z/2, 0));
        v4 = new PVector(modelX(-t.z/2, t.z/2, 0),modelY(-t.z/2, t.z/2, 0));

        popMatrix();
        isNewTrial = false;
      }


      drawQuad();
      //Target t = targets.get(trialIndex);
      //drawQuad(width/2+t.x+screenTransX,height/2+t.y+screenTransY,t.z,(t.rotation));
      fill(0);




      //===========DRAW TARGETTING SQUARE=================
      pushMatrix();

      translate(width/2,height/2); //center the drawing coordinates to the center of the screen
      fill(188);
      ellipse(-250,-250, radius, radius);
      ellipse(250,250, radius, radius);
      ellipse(-250,250, radius, radius);
      ellipse(250,-250, radius, radius);


      rotate(radians(screenRotation));

      //custom shifts:
      //translate(screenTransX,screenTransY); //center the drawing coordinates to the center of the screen

      fill(255,100); //set color to semi translucent

      rect(0,0,screenZ,screenZ);


      popMatrix();

      //scaffoldControlLogic(); //you are going to want to replace this!
      textFont(createFont("Arial", inchesToPixels(.3f))); 
      text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
     
      
     // if(checkForSuccess())
       fill(0,255,0);
     // else
      //  fill(150);
      rect(width-60,0,100,200);
      
      
      fill(0);
      textFont(createFont("Arial", inchesToPixels(.1f))); 
      text("Done", width-60, 50);

      colorQuads();

    }

    private void colorQuads() {
      fill(0,210,255,100);//blue
      //fill(210,0,0,128);
      
      if(isVertexNearTarget(width/2 - screenZ/2, height/2- screenZ/2))
        rect(width/2 - screenZ/4, height/2- screenZ/4, screenZ/2, screenZ/2);

      if(isVertexNearTarget(width/2 + screenZ/2, height/2- screenZ/2))
        rect(width/2 + screenZ/4, height/2- screenZ/4, screenZ/2, screenZ/2);

      if(isVertexNearTarget(width/2 + screenZ/2, height/2 + screenZ/2))
        rect(width/2 + screenZ/4, height/2 + screenZ/4, screenZ/2, screenZ/2);

      if(isVertexNearTarget(width/2 - screenZ/2, height/2 + screenZ/2))
        rect(width/2 - screenZ/4, height/2 + screenZ/4, screenZ/2, screenZ/2);


    }

    private boolean isVertexNearTarget(float x, float y)
    {
      for(int i=0;i<quad.getVertexCount();i++)
      {
        if(dist(quad.getVertexX(i),quad.getVertexY(i),x,y)<=inchesToPixels(.05f))
          return true;
      }

      return false;
    }

    public void mousePressed()
    {
      if(firstClick)
      {
        if (quadtTime == 0)
          quadtTime = millis();
      }
      firstClick = false;
    }
    public void mouseDragged() 
    {

      if(dist(v1.x, v1.y, mouseX, mouseY)<radius)
      {
        v1.x = mouseX;
        v1.y = mouseY;
      }
      else  if(dist(v2.x, v2.y, mouseX, mouseY)<radius)
      {
        v2.x = mouseX;
        v2.y = mouseY;
      }
      else  if(dist(v3.x, v3.y, mouseX, mouseY)<radius)
      {
        v3.x = mouseX;
        v3.y = mouseY;
      }
      else  if(dist(v4.x, v4.y, mouseX, mouseY)<radius)
      {
        v4.x = mouseX;
        v4.y = mouseY;
      }
      else if(isWithinPolygon())
      {
        if(prevMouseX==-1)  
          prevMouseX = mouseX;
        if(prevMouseY==-1)  
          prevMouseY = mouseY;

        v1.x+=  mouseX-prevMouseX;
        v2.x+=  mouseX-prevMouseX;
        v3.x+=  mouseX-prevMouseX;
        v4.x+=  mouseX-prevMouseX;

        v1.y+=  mouseY-prevMouseY;
        v2.y+=  mouseY-prevMouseY;
        v3.y+=  mouseY-prevMouseY;
        v4.y+=  mouseY-prevMouseY;

        prevMouseY = mouseY;
        prevMouseX = mouseX;
      }
      adjustTarget();
    }

    private void adjustTarget()
    {
      if(trialIndex>=trialCount)
        return;

      Target t = targets.get(trialIndex);

      t.x =  v1.x;
      t.y = v1.y;
      t.rotation = 0;

      float denom = (v1.x - v3.x)*(v4.y - v2.y) - (v1.y - v3.y)*(v4.x - v2.x);

      float centroidX = ((v1.x*v3.y - v1.y*v3.x)*(v4.x - v2.x) - (v1.x - v3.x)*(v4.x*v2.y - v4.y*v2.x) )/denom;
      float centroidY = ((v1.x*v3.y - v1.y*v3.x)*(v4.y - v2.y) - (v1.y - v3.y)*(v4.x*v2.y - v4.y*v2.x) )/denom;

      t.x = centroidX - width/2;
      t.y = centroidY - height/2;

      float d1 = dist(v1.x,v1.y,v3.x,v3.y)*dist(v2.x,v2.y,v4.x,v4.y)/2;
      t.z = sqrt(d1);
    }

    private void drawQuad() {
      //fill(0,191,255);//blue
      
      fill(210,0,0,100); //red

      quad = createShape();
      //quad = createShape(RECT,0,0,100,100);
      quad.beginShape();

      quad.vertex(v1.x,v1.y);
      quad.vertex(v2.x,v2.y);
      quad.vertex(v3.x,v3.y);
      quad.vertex(v4.x,v4.y);


      fill(0);
      ellipse(v1.x,v1.y, radius, radius);
      ellipse(v2.x,v2.y, radius, radius);
      ellipse(v3.x,v3.y, radius, radius);
      ellipse(v4.x,v4.y, radius, radius);

      quad.endShape(CLOSE);
      shape(quad);



    }



    public void mouseReleased()
    {
      //check to see if user clicked middle of screen
      // if (dist(width/2, height/2, mouseX, mouseY)<inchesToPixels(.5f))

      prevMouseX = -1;
      prevMouseY = -1;

     // rect(width-60,0,100,200);
      if (mouseX>=width -100 && mouseY<=200)
      {
        if (userDone==false && !checkForSuccess())
          errorCount++;

        //and move on to next trial
        trialIndex++;
        isNewTrial = true;
        screenTransX = 0;
        screenTransY = 0;

        if (trialIndex==trialCount && userDone==false)
        {
          userDone = true;
          finishTime = millis();
        }
      }
    }

    //function for testing if the overlap is sufficiently close
    //Don't change this function! Check with Chris if you think you have to.  
    public boolean checkForSuccess()
    {
      Target t = targets.get(trialIndex);
      boolean closeDist = dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f); //has to be within .1"
      boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
      boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"
      println("Close Enough Distance: " + closeDist);
      println("Close Enough Rotation: " + closeRotation + " ("+(t.rotation+360)%90+","+ (screenRotation+360)%90+")");
      println("Close Enough Z: " + closeZ);
      return closeDist && closeRotation && closeZ;
    }



    double calculateDifferenceBetweenAngles(float a1, float a2)
    {
      a1+=360;
      a2+=360; 
      if (abs(a1-a2)>45)
        return abs(abs(a1-a2)%90-90);
      else
        return abs(a1-a2)%90;
    }


    public boolean isWithinPolygon()
    {
      int i, j;
      boolean c=false;
      int sides = quad.getVertexCount();
      //quad.getVertex(i)
      for (i=0,j=sides-1;i<sides;j=i++) {
        if (( ((quad.getVertex(i).y <= mouseY) && (mouseY < quad.getVertex(j).y)) || ((quad.getVertex(j).y <= mouseY) && (mouseY < quad.getVertex(i).y))) &&
            (mouseX < (quad.getVertex(j).x - quad.getVertex(i).x) * (mouseY - quad.getVertex(i).y) / (quad.getVertex(j).y - quad.getVertex(i).y) + quad.getVertex(i).x)) {
          c = !c;
        }
      }
      return c;
    }
  
  