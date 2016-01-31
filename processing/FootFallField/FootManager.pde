
// manages maintaining the list of feet

class FootManager
{
  Serial myPort;
  Background background = new Background();
 
  int rotationCounter = 0;
  
  //ArrayList<Reading> newReadings = new ArrayList<Reading>();

  // Values for when we're spotting objects by looking for runs of similar data
  int currentFootRange;  // lidar range in cm
  int currentFootTick;   // angle in the range 0 to ticksPerRev/2, in other words 0 to 6400
  boolean gotCurrentFoot;
  
  FootManager()
  {
    if( demoMode )
      makeTestFeet();
  }
  
  void makeTestFeet()
  {
      // make some test feet
    FootFallField.readings.add(new Reading(-180, 190, millis() - 500,0));
    FootFallField.readings.add(new Reading(-140, 210, millis(),0 ));
  }
  
  void draw()
  {
    if( demoMode )
      moveTestFeet();
      
    background.draw();
  }
  
  


  void moveTestFeet()
  {
    int now = millis();
    
    for( Reading reading : FootFallField.readings)
      if( now - reading.millis > 1000 )    // move each foot every second
      {
        reading.x += 80;
        if( reading.x > FootFallField.calibration.maxLidarX())
          reading.x = FootFallField.calibration.minLidarX() + reading.x - FootFallField.calibration.maxLidarX();
          
        reading.millis = now;
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
    myPort.buffer(5);
  }
  
void serialEvent (Serial aPort) {
  
    readAndProcessSerial();
  }
  
int readAndProcessSerialCount = 0;
  void readAndProcessSerial()
  {
    /*
        print("readAndProcessSerial ");
    println(readAndProcessSerialCount ++);
    */
    
  while(myPort.available() > 0) 
  {
    
    int nRead = myPort.readBytes(inBuffer);
    //print("read ");
    //println(nRead);
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
  if( pendingBytes.size() < 1 )
  {
    println("nextByte - no byte!");
    return 0;
  }
  return pendingBytes.get(0);
}

byte scanByte()
{
  if( pendingBytes.size() < 1 )
  {
    println("scanByte - no byte!");
    return 0;
  }
  byte b = pendingBytes.get(0);
  pendingBytes.remove(0);    //TODO - expensive way to manage fifo buffer - find a quicker way
  return b;
}


void parseBuffer()
{
  
  parsePos = 0;
  while( true )
  {
    Reading reading;
    
    if( pendingBytes == null || pendingBytes.size() < 5 ) // if we don't have 5 byes, do nothing and wait for more
      break;
    
      /*
    for( int i = 0; i < 5; i ++ )
    {
      print( (int) pendingBytes.get(i));
      print(" ");
    }
    println("");
  */
    if( scanStart())
    {
      currentFootRange = -1;
      currentFootTick = -1;
      gotCurrentFoot = false;
      
      rotationCounter++;
      // Start of a fresh rotation, so hand the list we build during the last rotation to the UI
      // and start building a new list
      
      // Avoid simultaneous-modification  trouble by supplying a whole new list at the end of each scan
      // TODO - could reduce latency by updating the active list in realtime, not in batch
      //FootFallField.readings = newReadings;
      //newReadings = new ArrayList<Reading>();
      
      
       print("got ");
       print(FootFallField.readings.size());
       println(" readings");
       print(FootFallField.readings.size());
       println(" feet");
     
       //<>//
      println("scanStart");
    }
    else if(( reading = scanFoot()) != null)
    {
      //reading.printDiag();
      // add a new foot

      addReading( reading, FootFallField.readings );
      updateCurrentFoot(reading); //<>//
     
    }
    else
    {
      if( pendingBytes.size() >= 5 )
      {
        // must have lost sync, scan to next zero
        println("lost sync");
        scanToNull(); //<>//
      }
    }
  }

  
}

void updateCurrentFoot( Reading reading )
{
  if( reading.isBackground || reading.range <= 0 ||                         // no object
      (gotCurrentFoot && Math.abs(currentFootRange - reading.range) > 10 ))  // range has changed a lot
  {
    if( gotCurrentFoot )  // reached the end of an object
    {
      
      // TODO = should got to last point not this one!
      // Why not use the array we just added to ?
      
      int range = currentFootRange; //TODO - should use an average
      int tick = (currentFootTick + reading.tick) / 2;  // in the middle
      Reading newFoot = new Reading( range, tick, reading.millis, reading.rotationCounter );
      addReading( newFoot, FootFallField.feet );
      
    }
    
    gotCurrentFoot = false;
       currentFootRange = -1;
    currentFootTick = -1;
  }
 
}
void addReading( Reading reading, ArrayList<Reading> readings )
{
  background.accumulateBackground( reading );
  reading.isBackground = background.isPastBackground( reading );
      
  boolean inserted = false;
  // remove all feet from older runs and insert this one
  // keep feet in tick order
  synchronized( readings )
  {
    for( int i = 0; i < readings.size(); )
    {
      Reading target = readings.get(i);
      if( target.rotationCounter < reading.rotationCounter &&   // target is from an earlier run
          target.tick <= reading.tick )                          // and is at a smaller angle
      {
        // remove the old, add the new
        if( ! inserted )
        {
          readings.set(i, reading); // if this is the first obsolete one, replace it with the new one
          i++;
          inserted = true;
        }
        else
        {
          readings.remove(i); // just remove later obsolete ones
        }
        
      }
      else if( target.tick > reading.tick )
      {
        if( ! inserted )
        {
          readings.add(i, reading); // got past its place in the list, just insert it
          inserted = true;
        }
        break;
      }
      else
      {
        i++;
      }
    }
    
    if( ! inserted )
          FootFallField.readings.add(reading); // put it on the end
  }
}

void scanToNull()
{
  //println("scanToNull start");
  while( nextByte() != 0 && pendingBytes.size() > 0)
    scanByte();
  //println("scanToNull end");
}

// five zeros means the start of a new rotation, if first byte is not zero consume nothing
boolean scanStart()
{
  //println("scanStart start");
  for( int i = 0; i < 5; i ++ )
  {
    if( nextByte() == 0 )
      scanByte();
    else
    {
      //println("scanStart false");
      return false;
    } 
  }
  //println("scanStart true");
  return true;
} 

final static int BAD_WORD = (int) - Reading.ticksPerRev;
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

Reading scanFoot()
{
  //println("scanFoot start");
  
  if( pendingBytes.size() < 5 )
  {
    //println("scanFoot - not enough data");
    return null;
  }
  
  int range = scanWord();
  if( range == BAD_WORD )
  {
    //println("scanFoot - no range");
    return null;
  }
  
  int tick = scanWord();
  if( tick == BAD_WORD )
  {
    //println("scanFoot - no tick");
    return null;
  }
    
  if( nextByte() == 0 )
  {
    scanByte();
    //println("scanFoot success");
    return new Reading( range, tick, rotationCounter );
  }
  
  //println("scanFoot - no terminator");
  return null;
}

}