
// manages maintaining the list of feet

class FootManager
{
  Serial myPort;
  
  FootManager()
  {
    if( demoMode )
      makeTestFeet();
    
  }
  
  void makeTestFeet()
  {
      // make some test feet
    FootFallField.feet.add(new Foot(-180, 190, millis() - 500));
    FootFallField.feet.add(new Foot(-140, 210, millis() ));
  }
  
  void draw()
  {
    if( demoMode )
      moveTestFeet();
  }
  
  void moveTestFeet()
  {
    int now = millis();
    
    for( Foot foot : FootFallField.feet)
      if( now - foot.millis > 1000 )    // move each foot every second
      {
        foot.x += 80;
        if( foot.x > FootFallField.calibration.maxLidarX())
          foot.x = FootFallField.calibration.minLidarX() + foot.x - FootFallField.calibration.maxLidarX();
          
        foot.millis = now;
      }
  }
  
  void openPort(FootFallField context)
  {
    if( demoMode )
      return;
      
    println("Serial ports are");  
    println(Serial.list()); // print the available serial ports
    
    String portName = Serial.list()[5]; //change the 0 to a 1 or 2 etc. to match your port
    
    myPort = new Serial(context, portName, 115200);
    myPort.buffer(64);
  }
  
  void serialEvent (Serial myPort) {
  
  while(myPort.available() > 0) 
  {
    
    int nRead = myPort.readBytes(inBuffer);
    print("read ");
    println(nRead);
    bufferLength = nRead;
    for( int i = 0; i < nRead; i ++ )
      pendingBytes.add(inBuffer[i]);
    
    
  }
  
  parseBuffer();
}

byte[] inBuffer = new byte[128];
int bufferLength = 0;
int parsePos;
ArrayList<Byte> pendingBytes = new ArrayList<Byte>();

byte nextByte()
{
  return pendingBytes.get(0);
}

byte scanByte()
{
  byte b = pendingBytes.get(0);
  pendingBytes.remove(0);
  return b;
}


void parseBuffer()
{
  
  parsePos = 0;
  while( true )
  {
    Foot foot;
    
    if( pendingBytes.size() >= 5 ) // if we don't have 5 byes, do nothing and wait for more
    {
      if( scanStart())
      {
         print("got ");
         print(FootFallField.feet.size());
         println("feet");
        // Start of rotation, clear old feet
        FootFallField.feet.clear(); //<>//
        println("scanStart");
      }
      else if(( foot = scanFoot()) != null)
      {
        foot.printDiag();
        // add a new foot
        FootFallField.feet.add(foot); //<>//
       
      }
      else
      {
        // must have lost sync, scan to next zero
        println("lost sync");
        scanToNull(); //<>//
      }
    }
  }
  
}

void scanToNull()
{
  while( nextByte() != 0 )
    scanByte();
}

// five zeros means the start of a new rotation, if first byte is not zero consume nothing
boolean scanStart()
{
  for( int i = 0; i < 5; i ++ )
  {
  if( nextByte() == 0 )
    scanByte();
  else
    return false;
    
  }
  
  return true;
} 

final static int BAD_WORD = (int) -Foot.ticksPerRev;
int scanWord()
{

    int b1 = scanByte();
    if( b1 == 0 )
      return BAD_WORD;
      
          int b2 = scanByte();
    if( b2 == 0 )
      return BAD_WORD;
      
    return (b1 & 0x7f) + ((b2 & 0x7f) << 7);
      
}

Foot scanFoot()
{
  int range = scanWord();
  if( range == BAD_WORD )
    return null;
    
  int tick = scanWord();
  if( tick == BAD_WORD )
    return null;
    
  if( nextByte() == 0 )
  {
    scanByte();
    return new Foot( range, tick );
  }
  
  return null;
}

}