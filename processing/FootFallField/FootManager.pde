
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
          foot.x = FootFallField.calibration.minLidarX();
          
        foot.millis = now;
      }
  }
  
  void openPort(FootFallField context)
  {
    if( demoMode )
      return;
      
    println("Serial ports are");  
    println(Serial.list()); // print the available serial ports
    
    String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port
    
    myPort = new Serial(context, portName, 115200);
    myPort.buffer(64);
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


void parseBuffer()
{
  /*
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
  */
}
}