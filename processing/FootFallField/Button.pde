class Button
{
    float x;   // in lidar space in cm
    float y;
    float diameter; 
    
    PVector screenPos;
    int screenDiameter;
    
    final static int WAITING = 0;   // Not seen a foot yet (or seen one and given up)
    final static int TIMING = 1;    // Foot must stay put
    final static int SHOWING_PRESSED = 2;   // Pressed and locked on, staying visible for a second for UI feedback
    final static int LOCKED = 3;      // Done, finished, on forever
    int stateStartMillis;
    
    int state;
    
    public Button( float _x, float _y, float _diameter )
    {
      x = _x;
      y = _y;
      diameter = _diameter;
      
      screenPos = FootFallField.calibration.screenPosForXY( x, y );
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
      for( Reading foot : feet )
        if( foot.distanceFrom( x, y ) < diameter/2 ) 
          return true;
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
            if( now - stateStartMillis > 3000 )
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
    state = newState;
    stateStartMillis = millis();
  }
  
  void drawState()
  {
    
   float angle = 0;
   
   if( state != LOCKED && state != SHOWING_PRESSED) // rotate all the time till we are locked
   {
     angle = (float) (millis() - stateStartMillis) * PI / 2000;
   }
    
    if( state == WAITING ) // show filled during the wait time, hollow at other times
    {
      strokeWeight(0);
      stroke(0); 
      fill(255); 
    }
    else
    {
      strokeWeight(10);
      stroke(255); 
      fill(0);  
    }
      
    arc(screenPos.x, screenPos.y, screenDiameter, screenDiameter, 0 + angle, HALF_PI+ angle, PIE);
    arc(screenPos.x, screenPos.y, screenDiameter, screenDiameter, PI + angle, PI+HALF_PI+ angle, PIE);
    
    if( state == SHOWING_PRESSED || state == LOCKED )
    {
      strokeWeight(10);
      stroke(255); // white outline circle to show a measured point
      fill(0,0);
      ellipse(screenPos.x, screenPos.y, screenDiameter * 1.5 ,screenDiameter * 1.5);
    }
  }
}