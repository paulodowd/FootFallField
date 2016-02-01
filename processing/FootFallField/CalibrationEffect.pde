
// Calibrate the Calibration so projector matches lidar

class CalibrationEffect implements Effect
{
  
  int currentX = 0;
  int currentY = 0;
  int startMillis = 0;
  int endMillis = 0;
  int n = -1;
  
    void start()
    {
      
    }
    
    
  void draw(ArrayList<Reading> readings, ArrayList<Reading> feet)
  {
    int now = millis();
    
    if( n == -1 || now - startMillis > 5000 ) // time to change
    {
      n++;
      startMillis = now;
      
      if( n > 5 )
      {
        n = -1;
        //TODO - calibrate and leave if we have enough
        return;
      }
    }

      
    PVector markerPos = markerForN( n );
    
    drawMarker( markerPos );
    
    
      
      
    synchronized( feet )  
    {
      if( feet.size() != 1 )
      {
        return;
      }
      
      if( now - startMillis < 2000 )
        return;
        
      
      Reading reading = feet.get(0);
      FootFallField.calibration.addPoint( reading, markerPos );
        
 
    }
    
    
    
  }
  
  PVector markerForN( int n )
  {
    switch( n )
    {
      case 0: return new PVector( width/2, height/2 );
      case 1: return new PVector( 0.1 * width, 0.1 * height );
      case 2: return new PVector( 0.9 * width, 0.1 * height );
      case 3: return new PVector( 0.1 * width, 0.9 * height );
      case 4: default: return new PVector( 0.9 * width, 0.9 * height );
    }
    

  }
  
  void drawMarker( PVector markerPos )
  {
    stroke(255); // white outline circle
    fill(255);
    arc(markerPos.x, markerPos.y, 80, 80, 0, HALF_PI, PIE);
    arc(markerPos.x, markerPos.y, 80, 80, PI, PI+HALF_PI, PIE);
  }
}