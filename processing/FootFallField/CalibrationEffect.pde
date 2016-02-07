
// Calibrate the Calibration so projector matches lidar

class CalibrationEffect implements Effect
{
  
  int currentX = 0;
  int currentY = 0;
  int startMillis = 0;
  int endMillis = 0;
  int n = -1;
  
  ArrayList<CalibrationPoint> points = new ArrayList<CalibrationPoint>();
    void start()
    {
      
    }
    
    
  void draw(ArrayList<Reading> readings, ArrayList<Reading> feet, ArrayList<Person> people)
  {
    int now = millis();
    
    if( n == -1 || now - startMillis > 10000 ) // time to change
    {
       nextPoint();
      
      if( n > 4 )
      {
        n = 0; // start again
        points = new ArrayList<CalibrationPoint>();
      }
    }

    drawExistingPoints();
    
    PVector markerPos = markerForN( n );
    
    if( now - startMillis < 5000 ) // 2 secs to get into position
    {
      drawMarker( markerPos, true );
      return;
    }
    
    drawMarker( markerPos, false );
    
      
      
    synchronized( feet )  
    {
      if( feet.size() != 1 )
      {
        return;
      }
      
      
        
      
      Reading reading = feet.get(0);
      points.add( new CalibrationPoint( reading, markerPos ));
      if( points.size() == 4 )
      {
        FootFallField.calibration.setPoints( points );
        
        return;
      }
      nextPoint();
        
 
    }
    
    
    
  }
  
  void drawExistingPoints()
  {
    // draw completed points with an outline circle
    for( CalibrationPoint point : points )
    {
      drawMarker( point.screenPos, false );
      strokeWeight(10);
      stroke(255); // white outline circle to show a measured point
      fill(0,0);
      ellipse(point.screenPos.x, point.screenPos.y, 120,120);
    }
  }
  void nextPoint()
  {
    int now = millis();
     n++;
      startMillis = now;
  }
  
  PVector markerForN( int n )
  {
    switch( n )
    {
      case 0: return new PVector( 0.1 * width, 0.1 * height );
      case 1: return new PVector( 0.9 * width, 0.1 * height );
      case 2: return new PVector( 0.9 * width, 0.9 * height );
      case 3: default: return new PVector( 0.1 * width, 0.9 * height );
    }
    

  }
  
  void drawMarker( PVector markerPos, boolean fill )
  {
    
    
    
    if( fill )
    {
      strokeWeight(0);
      stroke(0); 
      fill(255); // show filled during the wait time
    }
    else
    {
      strokeWeight(10);
      stroke(255); 
      fill(0);  // show empty when live
    }
      
    arc(markerPos.x, markerPos.y, 80, 80, 0, HALF_PI, PIE);
    arc(markerPos.x, markerPos.y, 80, 80, PI, PI+HALF_PI, PIE);
  }
}