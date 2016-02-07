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

public static boolean demoMode = true; // set true to run without a real lidar


Effect calibrationEffect;
Effect currentEffect;
Effect debugEffect;

public static Calibration calibration;
public static ArrayList<Reading> readings = new ArrayList<Reading>(); // All the Lidar readings
public static ArrayList<Reading> feet = new ArrayList<Reading>();     // Foot locations inferred from clusters of Lidar points

public static FootManager footManager;
public static PersonManager personManager;

void setup() 
{
  
  size(1200,700); //fixed canvas size
  
  calibration = new Calibration( width, height );
  
  footManager = new FootManager();
  personManager = new PersonManager();
  
  footManager.openPort(this);
  
  debugEffect = new BlobEffect();
  
  if( ! demoMode )
    calibrationEffect = new CalibrationEffect();
}

void changeEffect(Effect effect)
{
  currentEffect = effect;
  currentEffect.start();
}

void draw() 
{

      
    // clear to hide old blobs
    fill( 0 );
    rect( 0,0, width, height );
    
    if( ! demoMode )
      if( ! calibration.isCalibrated())  
        calibrationEffect.draw(readings, feet, personManager.people);
    
  if( currentEffect != null )
    currentEffect.draw(readings, feet, personManager.people);
    
  if( debugEffect != null )
    debugEffect.draw(readings, feet, personManager.people); // draw some blobs so we can see feet, people etc
   
  footManager.draw();                  // draws the background
}


void serialEvent (Serial port) 
{
  footManager.serialEvent(port);
}