/*

  FootFallField
  
  https://github.com/jarkman/FootFallField
  
  Talks to an Arduino running the foot_fall_field_lidar sketch,
  which supplies a list of detected feet.
  
  Generates a visualisation from those foot positions, which will be projected 
  from above so as to align with the feet.
  
  Set demoMode to true if you want to run this without a lidar. Then FootManager 
  will make you simulated feet.



*/

import processing.serial.*;

public static boolean demoMode = false; // set true to run without a real lidar


Effect currentEffect;

public static Calibration calibration;
public static ArrayList<Reading> readings = new ArrayList<Reading>();
public static ArrayList<Reading> feet = new ArrayList<Reading>();
public static FootManager footManager;

void setup() 
{
  
  size(1200,700); //fixed canvas size
  
  calibration = new Calibration( width, height );
  
  footManager = new FootManager();
  
  footManager.openPort(this);
  
  changeEffect( new BlobEffect());
}

void changeEffect(Effect effect)
{
  currentEffect = effect;
  currentEffect.start();
}

void draw() 
{

  if( currentEffect != null )
    currentEffect.draw(readings, feet);
    
   
  footManager.draw();
}


void serialEvent (Serial port) 
{
  footManager.serialEvent(port);
}