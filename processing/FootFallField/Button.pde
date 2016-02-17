class Button
{
    final static int HOLD_TIME = 3000; //foot must be in place for this long
  
    PImage image;
    float x;   // in lidar space in cm
    float y;
    float diameter; 
    
    PVector screenPos;
    int screenDiameter;
    boolean forCalibration = false; // controls special behaviour for calibration
    
    
    final static int WAITING = 0;   // Not seen a foot yet (or seen one and given up)
    final static int TIMING = 1;    // Foot must stay put
    final static int SHOWING_PRESSED = 2;   // Pressed and locked on, staying visible for a second for UI feedback
    final static int LOCKED = 3;      // Done, finished, on forever
    int stateStartMillis;
    
    int state;
    
    public Button( String imageName, float _x, float _y, float _diameter )
    {
      if( imageName != null )
      image = loadImage(imageName);

      x = _x;
      y = _y;
      diameter = _diameter;
      
      screenPos = FootFallField.calibration.screenPosForXY( x, y );
      screenDiameter = (int) FootFallField.calibration.screenDistanceNear( x, y, diameter );
      
      stateStartMillis = millis();
   
      state = WAITING;
    }
    
    public Button( PVector _screenPos ) // special constructor for use in calibration
    {
      forCalibration = true;
      x = -1;  // doon't know these yes, wil make them up from the first foot we see
      y = -1;
      diameter = 40;
      
      screenPos = _screenPos;
      
      screenDiameter = (int) FootFallField.calibration.screenDistanceNear( x, y, diameter );
      
      stateStartMillis = millis();
   
      state = WAITING;
    }
    
   void draw(ArrayList<Reading> readings, ArrayList<Reading> feet, ArrayList<Person> people)
   {
      int now = millis();
      
      updateState( feet );
      
      drawState();
   }
    
   Reading getReading() // a way to read out x, y for calibration purposes
   {
     return new Reading( (int) x, (int) y, millis(), 0 );
   }
   
   boolean isLocked()
   {
     return state == LOCKED ;
   }
   
   void reset()
   {
     state = WAITING;
   }
   
  boolean gotFoot( ArrayList<Reading> feet )
  {
    synchronized( feet )
    {
      if( forCalibration )
      {
        if( state == WAITING && millis() - stateStartMillis < 3000 ) // ignore feet for first 3 secs to give time to get there
          return false;
          
        if( feet.size() == 1 && state == WAITING && y < 0) // must have exactly one foot for calibration
        {
          x = feet.get(0).x; // set x & y from the first foot we see. foot will have to stay in place for the button time to be confirmed
          y = feet.get(0).y;
          return true;
        }
        
        if( y < 0 )
          return false; // don't have a position yet. don't check for matches
      }
      

      for( Reading foot : feet )
        if( foot.distanceFrom( x, y ) < diameter/2 ) 
        {
          //TODO - if forCalibration, could rolling-average x,y with the measured position to get a better fix
          return true;
        }
    }
    
    return false;
  }
  
  void updateState(ArrayList<Reading> feet)
   {
      int now = millis();
      boolean gotFoot = gotFoot(feet);
      
      switch( state )
      {
        case WAITING:   // Not seen a foot yet (or seen one and given up)
          if( gotFoot )
            changeState( TIMING );
        break;
        
        case TIMING:    // Foot must stay put
          if( ! gotFoot )
            changeState( WAITING );
          else
            if( now - stateStartMillis > HOLD_TIME )
              changeState( SHOWING_PRESSED );
        break;
            
        case SHOWING_PRESSED:   // Pressed and locked on, staying visible for a second for UI feedback
          if( now - stateStartMillis > 2000 )
              changeState( LOCKED );
        break;
            
        case LOCKED:
        break;
        
      }
 
   }
   
  void changeState( int newState )
  {
    if( forCalibration )
      if( newState == WAITING )
        y = -1; // forget our position when we go back to waiting, next single foot will set it again
        
    state = newState;
    stateStartMillis = millis();
  }
  
  void drawState()
  {
    
   float angle;
   float segmentWidth;
   float timeInState = (float) (millis() - stateStartMillis);
   
 
   if( state != LOCKED && state != SHOWING_PRESSED) // rotate all the time till we are locked
     angle = timeInState * PI / 2000;
   else
     angle = 0;
    
    switch( state )
      {
        case WAITING:   // Not seen a foot yet (or seen one and given up)
          segmentWidth = HALF_PI;
        break;
        
        case TIMING:    // Foot must stay put
          segmentWidth = 0.1 + 0.8 * timeInState * PI / HOLD_TIME;
        break;
            
        case SHOWING_PRESSED:  
        case LOCKED:
        default:
          segmentWidth = HALF_PI;
        break;
        
      }
    if( state == WAITING ) // show filled during the wait time, hollow at other times
    {
      strokeWeight(0);
      stroke(0); 
      fill(128); 
    }
    else
    {
      strokeWeight(10);
      stroke(128); 
      fill(0);  
    }
      
    ellipseMode(CENTER); 
    arc(screenPos.x, screenPos.y, screenDiameter, screenDiameter, 0 + angle, segmentWidth+ angle, PIE);
    arc(screenPos.x, screenPos.y, screenDiameter, screenDiameter, PI + angle, PI+segmentWidth+ angle, PIE);
    
    if( state == SHOWING_PRESSED || state == LOCKED )
    {
      strokeWeight(10);
      stroke(255); // white outline circle to show pressing is done
      fill(0,0);
      ellipse(screenPos.x, screenPos.y, screenDiameter * 1.5 ,screenDiameter * 1.5);
    }
    
    if( image != null )
    {
      /*
      strokeWeight(10);
      stroke(255); // white outline circle to show pressing is done
      fill(0,0);
      
      rect( screenPos.x-screenDiameter/2, screenPos.y-screenDiameter/2, screenDiameter, screenDiameter); 
      */
      
      imageMode(CENTER);
  
      image(image, screenPos.x, screenPos.y, screenDiameter*0.7, screenDiameter*0.7); 
    }
   
  }
}