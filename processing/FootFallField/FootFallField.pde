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

public static boolean demoMode = true; // set true to run without a real lidar, with simulated footsteps
public static boolean usingMirror = false; // set true to run when projecting via a mirror to get left/right swap


Effect calibrationEffect;
Effect currentEffect;
Effect debugEffect;
MenuEffect menuEffect;

public static Calibration calibration;                                  // Manages mapping from lidar space to screen space

public static FootManager footManager;                                  // Manages serial comms, maintains lists of readings and feet, makes simulated feet in demo mode
public static PersonManager personManager;                              // Manages an array of people inferred from feet

void setup() 
{
  
  //size(1200,700); //fixed canvas size to match projector
  fullScreen();
  
  calibration = new Calibration( width, height );
  
  footManager = new FootManager();
  personManager = new PersonManager();
  
  footManager.openPort(this);
  
  debugEffect = new DebugEffect();
  

   calibrationEffect = new CalibrationEffect();
   
   
   menuEffect = new MenuEffect();
   // Add each effect to the menu here so it can offer them as choices 
   menuEffect.addEffect(new LineEffect());
   menuEffect.addEffect(new RippleEffect());
   menuEffect.addEffect(new SplatEffect());
    

   changeEffect(menuEffect.effects.get(0));
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

    doMouseFeet();
    
    boolean doCalibration = false;
    
    if( ! demoMode )
      if( ! calibration.isCalibrated())
        doCalibration = true;
        
   if( doCalibration )
   {
        calibrationEffect.draw(footManager.readings, footManager.feet, personManager.people);
   }
   else
   {
      
      if( currentEffect != null )
        currentEffect.draw(footManager.readings, footManager.feet, personManager.people);
        
      menuEffect.draw(footManager.readings, footManager.feet, personManager.people);

   }
   
  if( debugEffect != null )
    debugEffect.draw(footManager.readings, footManager.feet, personManager.people); // draw some blobs so we can see feet, people etc
   
  footManager.draw();                  // draws the background
  
}

Reading mouseFoot = null;

void doMouseFeet()
{
  if( ! demoMode )
    return;
    
  synchronized( footManager.feet )
  {
    if( mouseFoot != null )
    {
      footManager.feet.remove( mouseFoot );
      mouseFoot = null;
    }
    
      
    if( mousePressed )
    {
      mouseFoot = calibration.readingForScreenPos( mouseX, mouseY);
      footManager.feet.add( mouseFoot );
    }

  }
  
  if( mousePressed )
    notifyNewFoot( mouseFoot );
}


void notifyNewFoot( Reading foot ) // A new foot arrived, tell the current effect to handle it
{
  if( currentEffect != null )
    currentEffect.notifyNewFoot( foot );
}

void serialEvent (Serial port)     // Some bytes arrived from the lidar, tell the foot amanger to handle them
{
  footManager.serialEvent(port);
}