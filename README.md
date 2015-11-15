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

    boolean isNewTrial = true;

    int tapCount = 0;

    //final int screenPPI = 120; //what is the DPI of the screen you are using?
    final int screenPPI = 326; 
    //Many phones listed here: https://en.wikipedia.org/wiki/Comparison_of_high-definition_smartphone_displays 

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

      width = 652;
      height = 1141;
      size(652, 1141, P2D);

      frameRate(300);
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
        //println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
      }

      Collections.shuffle(targets); // randomize the order of the button;

    }

    public void draw() {

      background(80); //background is light grey
      fill(200);
      noStroke();

      if (quadtTime == 0)
        quadtTime = millis();

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

        fill(255,0,0); //set color to semi translucent
        

        v1 = new PVector(modelX(0, 0, 0), modelY(0, 0, 0));
        v2 = new PVector(modelX(t.z, 0, 0), modelY(t.z, 0, 0));
        v3 = new PVector(modelX(t.z, t.z, 0), modelY(t.z, t.z, 0));
        v4 = new PVector(modelX(0, t.z, 0),modelY(0, t.z, 0));
        popMatrix();
      }
     
        drawQuad(0);
    

      //===========DRAW TARGETTING SQUARE=================
      pushMatrix();
      translate(width/2,height/2); //center the drawing coordinates to the center of the screen
      rotate(radians(screenRotation));

      //custom shifts:
      //translate(screenTransX,screenTransY); //center the drawing coordinates to the center of the screen

      fill(255,128); //set color to semi translucent
      rect(0,0,screenZ,screenZ);

      popMatrix();

      //scaffoldControlLogic(); //you are going to want to replace this!

      text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
      fill(0,0,255);
      //rect(10,50,50,50);
      rect(0,0,50,50);
      fill(255,128); 
      text("+", 15, 15);

    }


    private void adjustTarget()
    {
      if(trialIndex>=trialCount)
        return;

      Target t = targets.get(trialIndex);

      t.x =  v1.x;
      t.y = v1.y;
      t.rotation = 0;
      float d1 = dist(v1.x,v1.y,v3.x,v3.y)*dist(v2.x,v2.y,v4.x,v4.y)/2;
      t.z = sqrt(d1);
    }

    private void drawQuad(float rot) {
      fill(255,0,0);

      quad = createShape();
      //quad = createShape(RECT,0,0,100,100);
      quad.beginShape();

      quad.vertex(v1.x,v1.y);
      quad.vertex(v2.x,v2.y);
      quad.vertex(v3.x,v3.y);
      quad.vertex(v4.x,v4.y);

      quad.rotate(rot);
      
      quad.endShape(CLOSE);
      
      shape(quad);

    }



    public void mouseReleased()
    {
      //check to see if user clicked middle of screen
      // if (dist(width/2, height/2, mouseX, mouseY)<inchesToPixels(.5f))
      float XCord =  mouseX;
      //float YCord = inchesToPixels(.2f) + mouseY;
      float YCord = mouseY;
      if(tapCount==0)
        isNewTrial = false;
      if (mouseX>=0 && mouseX<=50 && mouseY>=0 && mouseY<=50)
      {
        if (userDone==false && !checkForSuccess())
          errorCount++;

        //and move on to next trial
        trialIndex++;
        isNewTrial = true;
        tapCount = 0;
        screenTransX = 0;
        screenTransY = 0;

        if (trialIndex==trialCount && userDone==false)
        {
          userDone = true;
          finishTime = millis();
        }
        return;
      }

      else if(tapCount%4==0)
      {
        v1.x = XCord;
        v1.y = YCord;
        adjustTarget();
        tapCount++;
      }
      else if(tapCount%4==1)
      {
        v2.x = XCord;
        v2.y = YCord;
        adjustTarget();
        tapCount++;
      }
      else if(tapCount%4==2)
      {
        v3.x = XCord;
        v3.y = YCord;
        adjustTarget();
        tapCount++;
      }
      else if(tapCount%4==3)
      {
        v4.x = XCord;
        v4.y = YCord;
        adjustTarget();
        tapCount++;
      }
    

    }

    //function for testing if the overlap is sufficiently close
    //Don't change this function! Check with Chris if you think you have to.  
    public boolean checkForSuccess()
    {
      Target t = targets.get(trialIndex);  
      boolean closeDist = dist(t.x,t.y,width/2 - 250,height/2 -250)<inchesToPixels(.1f); //has to be within .1"
      boolean closeRotation = abs(t.rotation - screenRotation)%90<5; //has to be within +-5 deg
      boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.1f); //has to be within .1"  
      println("Close Enough Distance: " + closeDist);
      println("Close Enough Rotation: " + closeRotation);
      println("Close Enough Z: " + closeZ);

      return closeDist && closeRotation && closeZ;  
    }
