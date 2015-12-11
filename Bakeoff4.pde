import java.util.ArrayList;
import java.util.Collections;
import ketai.sensors.*;



  KetaiSensor sensor;
  float cursorX, cursorY;
  float light = 0;
  PVector compass;
  boolean freeze = false;
  float freeze_rot  = 0.0f;
  boolean succes_trail = false;
  int succes_trail_count = 0;


  private class Target
  {
    int target = 0;
    int action = 0;
  }

  int trialCount = 5; //this will be set higher for the bakeoff
  int trialIndex = 0;
  ArrayList<Target> targets = new ArrayList<Target>();

  int startTime = 0; // time starts when the first click is captured
  int finishTime = 0; //records the time of the final click
  boolean userDone = false;
  int countDownTimerWait = 0;

  public void setup() {
    //size(600,600); //you can change this to be fullscreen
    
    size(600,1000);

    compass = new PVector();


    frameRate(100);
    sensor = new KetaiSensor(this);
    sensor.start();
    orientation(PORTRAIT);

    rectMode(CENTER);
    textFont(createFont("Arial", 40)); //sets the font to Arial size 20
    textAlign(CENTER);

    for (int i=0;i<trialCount;i++)  //don't change this!
    {
      Target t = new Target();
      t.target = ((int)random(1000))%4;
      t.action = ((int)random(1000))%2;
      targets.add(t);
      //println("created target with " + t.target + "," + t.action);
    }

    Collections.shuffle(targets); // randomize the order of the button;
  }

  public void draw() {

    background(80); //background is light grey
    //noStroke(); //no stroke

    countDownTimerWait--;

    if (startTime == 0)
      startTime = millis();

    if (trialIndex==targets.size() && !userDone)
    {
      userDone=true;
      finishTime = millis();
    }

    if (userDone)
    {
      text("User completed " + trialCount + " trials", width/2, 50);
      text("User took " + nfc((finishTime-startTime)/1000f/trialCount,1) + " sec per target", width/2, 150);
      return;
    }


    int x = width/2;
    int y = height/2;
    int ht = height-300;
    int length = 3*(ht)/4;

    strokeWeight(2);
    //line(x, y, x+cos(PI/2 - radians(compass.x))*length, y+sin(PI/2 - radians(compass.x))*length);

    
    drawArc(x, y, length, PI+QUARTER_PI, 2*PI - QUARTER_PI ,0);
    drawArc(x, y, length, - QUARTER_PI, QUARTER_PI,1);
    drawArc(x, y, length, QUARTER_PI, PI/2+QUARTER_PI,2);
    drawArc(x, y, length, PI/2+QUARTER_PI, PI+QUARTER_PI,3);
    
    if(succes_trail)
      succes_trail_count++;
    
    if(succes_trail && succes_trail_count >2)
      succes_trail = false;

    //fill(9,92,235);//blue
    fill(11,227,65);
    stroke(0);
    triangle(x-20, y -ht/2 , x+20, y -ht/2, x , y-ht/4+20 );



    if(freeze && trialIndex<targets.size())
    {
      //stroke(9,92,235);//blue
      stroke(0,255,255);
      strokeWeight(15);
      if (targets.get(trialIndex).action==0)
      {
        //text("UP", width/2, 100);
        
        line(x,0,x-50,80);
        line(x,0,x+50,80);
        line(x,height,x-50,height-80);
        line(x,height,x+50,height-80);
      }
      else
      {
        //text("DOWN", width/2, 100);
        line(width,y,width-50,y-30);
        line(width,y,width-50,y+30);
        line(0,y,30,y-30);
        line(0,y,30,y+30);
        
      }
      stroke(0);
    }
  }


  void drawArc(int x, int y, int length, float start, float end, int index)
  {
    float rot = radians((int)compass.x);
    //if(freeze)
      //rot = freeze_rot;
      

    fill(255);
    if(trialIndex<targets.size() && index == targets.get(trialIndex).target)
    {
      fill(186,20,73);


      float st = (start + rot)%(2*PI);
      float ed = (end + rot)%(2*PI);


      //println(degrees(st)+"::"+degrees(ed));

      if((st>=PI+QUARTER_PI || st<=3*PI/2) &&(ed>=3*PI/2 && ed<=7*PI/2))
      {
        freeze = true;
        freeze_rot = rot;
        fill(11,227,65);
      }
      else
        freeze = false;

    }
    
    if(succes_trail)
      fill(255,215,0);
    
    arc(x, y, length, length, start + rot, end + rot , PIE);

  }

  void onAccelerometerEvent(float x, float y, float z)
  {
    if (userDone)
      return;

    if (freeze && trialIndex<targets.size())
      {


        Target t = targets.get(trialIndex);

        if (((x)>3 && t.action==1) || ((y)>3 && t.action==0))
        {
          
          trialIndex++; //next trial!
          freeze = false;
          freeze_rot = 0.0f;
          succes_trail = true;
          succes_trail_count = 0;
        } 

        countDownTimerWait=30; //wait 0.5 sec before allowing next trial
      }
  }

  int hitTest() 
  {
    for (int i=0;i<4;i++)
      if (dist(300,i*150+100,cursorX,cursorY)<100)
        return i;

    return -1;
  }



  void onOrientationEvent(float x, float y, float z, long time, int accuracy) { //(8)
    compass.set(x,y,z);
    //compass = x;  
    // Azimuth angle between magnetic north and device y-axis, around z-axis.
    // Range: 0 to 359 degrees
    // 0=North, 90=East, 180=South, 270=West 
  }
