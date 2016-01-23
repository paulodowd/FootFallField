import processing.serial.*;

Serial myPort;
Effect currentEffect;

public static Calibration calibration;
public static ArrayList<Foot> feet = new ArrayList<Foot>();

void setup() 
{
  
  size(800,800); //make our canvas 200 x 200 pixels big
  
  calibration = new Calibration( width, height );
  
  println(Serial.list()); // print the available serial ports
  
  String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port
  
  myPort = new Serial(this, portName, 115200);
  myPort.buffer(64);
  
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
    currentEffect.draw();
}

void serialEvent (Serial myPort) {
  
  if(myPort.available() > 0) 
  {
    
    int nRead = myPort.readBytes(inBuffer);
    print("read ");
    println(nRead);
    bufferLength = nRead;
    parseBuffer();
    
  }
}

byte[] inBuffer = new byte[128];
int bufferLength = 0;
int parsePos;


void parseBuffer(byte[] inBuffer, int nRead)
{
  parsePos = 0;
  while( true )
  {
    if( isStart( inBuffer, parsePos ))
    {
    }
    else if( parseObject(inBuffer, parsePos))
    {
    }
    else
    {
      scanToNull();
    }
  }
}