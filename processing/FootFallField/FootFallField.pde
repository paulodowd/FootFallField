import processing.serial.*;

public static boolean demoMode = true; // set true to run without a real lidar


Effect currentEffect;

public static Calibration calibration;
public static ArrayList<Foot> feet = new ArrayList<Foot>();
public static FootManager footManager;

void setup() 
{
  
  size(800,800); //make our canvas 200 x 200 pixels big
  
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
  footManager.draw();
  
  if( currentEffect != null )
    currentEffect.draw();
}

void serialEvent (Serial port) {
  footManager.serialEvent(port);
}

 