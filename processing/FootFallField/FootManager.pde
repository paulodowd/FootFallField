
// manages parsing serial data from the lidar and maintaining the list of feet

class FootManager
{
  public ArrayList<Reading> readings = new ArrayList<Reading>();   // All the Lidar readings
  public ArrayList<Reading> feet = new ArrayList<Reading>();       // Foot locations inferred from clusters of Lidar points


  Serial myPort;
  Background background = new Background();
 
  int rotationCounter = 0;
  
  //ArrayList<Reading> newReadings = new ArrayList<Reading>();

  // Values for when we're spotting objects by looking for runs of similar data
  int currentFootStartRange;  // lidar range in cm
  int currentFootStartTick;   // angle in the range 0 to ticksPerRev/2, in other words 0 to 6400
    int currentFootEndRange;  // lidar range in cm
  int currentFootEndTick;   // angle in the range 0 to ticksPerRev/2, in other words 0 to 6400

  boolean gotCurrentFoot;
  
  FootManager()
  {
    if( ! debugCalibrate )
      if( demoMode )
        makeTestFeet();
  }
  
  void makeTestFeet()
  {
      // make some test feet
    feet.add(new Reading(-180, 195, millis() - 500, 0));
    feet.add(new Reading(-140, 205, millis(),0 ));
  }
  
  void draw()
  {
    if( demoMode )
      moveTestFeet();
    
    
    background.draw();
  }
  
  
  int testRotationMillis = 0;

  Reading lastMouseFoot = null;
  void addMouseFoot( Reading reading ) // add a foot from a mouse click
  {
      removeMouseFoot();
        
      lastMouseFoot = reading;  
      reading.millis = millis();
      reading.rotationCounter = rotationCounter;
        
      feet.add(reading);
      //updateCurrentFoot(reading);
      
      
      FootFallField.personManager.updateForFoot( reading );
      notifyNewFoot( reading );
  }
  
  void removeMouseFoot()
  {
    if( lastMouseFoot!= null )
        feet.remove( lastMouseFoot );
  }
  
  boolean isMouseFoot( Reading reading )
  {
    return reading != null && reading == lastMouseFoot ;
  }
  
  void moveTestFeet()
  {
    int now = millis();
    
    if( now - testRotationMillis > 500 ) // simulate rotationCounter increasing every half a second
    {
      testRotationMillis = now;
      rotationCounter++;
      FootFallField.personManager.cleanBeforeRotation( rotationCounter ); 
    }
    
    for( Reading reading : feet)
      if( now - reading.millis > 1000 )    // move each foot every second
        if( reading != lastMouseFoot )
        {
          reading.x += 80;
          if( reading.x > FootFallField.calibration.maxLidarX())
            reading.x = FootFallField.calibration.minLidarX() + reading.x - FootFallField.calibration.maxLidarX();
            
          reading.millis = now;
          reading.rotationCounter = rotationCounter;
          
          
          FootFallField.personManager.updateForFoot( reading );
          notifyNewFoot( reading );
        }
  }
  
  void openPort(FootFallField context)
  {
    if( demoMode )
      return;
      
    println("Serial ports are");  
    println(Serial.list()); // print the available serial ports
    
    String portName;
    if( true ) // on mac )
    {
      portName = Serial.list()[5]; //change the 0 to a 1 or 2 etc. to match your port
    }
    else
    { // on pi 
      portName = "/dev/ttyUSB0";
    }
    
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

      gotCurrentFoot = false;
      
      rotationCounter++;
      
      // Clean out old data from last rotation, if we didn't already clean it up in addReading()
      cleanReadingsBeforeRotation(readings, rotationCounter ); 
      cleanReadingsBeforeRotation( feet, rotationCounter ); 
      FootFallField.personManager.cleanBeforeRotation( rotationCounter ); 

       print("got ");
       print(readings.size());
       println(" readings");
       print(feet.size());
       println(" feet");
     
       //<>//
      println("scanStart");
    }
    else if(( reading = scanFoot()) != null)
    {
      //reading.printDiag();
      // add a new foot

      addReading( reading, readings );
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
  // We've got a new reading, we need to decide if it represents one or more of:
  // - nothing (if it has no range and we don't have a current foot)
  // - the start of a new foot (if we have no current foot and the reading does have a range)
  // - the continuation of an existing run of readings representing the current foot
  // - the end of the current foot (if the new reading has a very different range or no range from the current foot)
  
  // TODO - One complication is that the lidar is prone to report readings with spurious ranges at the start and end of an object.
  // They always have a range greater than that of the real object, sometimes by a little, sometimes by a lot
  // So, we need to reject readings that are adjacent to other readings with much greater lengths
  // That means we can't use the simple transition from one range to another to indicate a new, we need to ignore 
  //  solitary readings with ranges greater than their neighbour
  
  if( reading.isBackground || reading.range <= 0 ||                             // no object detected
      (gotCurrentFoot && Math.abs(currentFootEndRange - reading.range) > 10 ))  // range has changed a lot
  {
    if( gotCurrentFoot )  // reached the end of an object
    {
      
      // TODO = should got to last point not this one!
      // Why not use the array we just added to ?
      
      int range = (currentFootStartRange + currentFootEndRange)/2; 
      int tick = (currentFootStartTick + currentFootEndTick) / 2;  // in the middle
      Reading newFoot = new Reading( range, tick, reading.rotationCounter );
      synchronized( feet )
      {
        addReading( newFoot, feet );
        FootFallField.personManager.updateForFoot( newFoot );
        notifyNewFoot( reading );
      }
    }
    
    gotCurrentFoot = false;
       
  }
  
  if( ! reading.isBackground && reading.range > 0 )
    if( gotCurrentFoot )
    {
      // extend the current one
      currentFootEndRange = reading.range;
      currentFootEndTick = reading.tick;
    }
    else
    {
      // start a new current foot
      gotCurrentFoot = true;
      currentFootStartRange = reading.range;
      currentFootEndRange = reading.range;
      currentFootStartTick = reading.tick;
      currentFootEndTick = reading.tick;
  
    }
 
}

void cleanReadingsBeforeRotation( ArrayList<Reading> readings, int currentRotation ) // clean out any leftovers at the end of a rotaiton
{
  synchronized( readings )
  {
    for( int i = 0; i < readings.size(); )
    {
      Reading target = readings.get(i);
      if( target.rotationCounter < currentRotation && ! isMouseFoot(target))
      {
          readings.remove(i); 
      }
      else
      {
        i++;
      }
    }
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
          if( ! isMouseFoot(target))
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
          readings.add(reading); // put it on the end
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