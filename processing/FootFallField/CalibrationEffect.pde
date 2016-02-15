
// An Effect used to calibrate the Calibration so projected graphics can align with real-world object detected by lidar
// Will run once at boot time, shows a series of points which user needs to stand on to provide a reference


class CalibrationEffect extends Effect
{
  
  int currentX = 0;
  int currentY = 0;
  int startMillis = 0;
  int endMillis = 0;
  int n = -1;
  
  ArrayList<CalibrationPoint> points = new ArrayList<CalibrationPoint>();
  
  Button button = null;

    
  void draw(ArrayList<Reading> readings, ArrayList<Reading> feet, ArrayList<Person> people)
  {

    if( n == -1 ) // first time round
       nextPoint();


    drawExistingPoints();
    
    button.draw(readings, feet, people);
    
    if( button.isLocked())
    {
      points.add( new CalibrationPoint( button.getReading(), button.screenPos ));
      
      if( points.size() == 4 )
      {
        
        FootFallField.calibration.setPoints( points );
        
        return; // all done
      }
      nextPoint();
    }
    
    
      
   
    
  }
  
  void drawExistingPoints()
  {
    // draw completed points with an outline circle
    for( CalibrationPoint point : points )
    {
      drawMarker( point.screenPos, false, true );
      
    }
  }
  void nextPoint()
  {
    int now = millis();
    n++;
    startMillis = now;
    if( n > 4 )
    {
      n = 0; // start again
      points = new ArrayList<CalibrationPoint>();
    }
    
    button = new Button( markerForN( n ));
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
  
  void drawMarker( PVector markerPos, boolean fill, boolean circle )
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
    
    if( circle )
    {
      strokeWeight(10);
      stroke(255); // white outline circle to show a measured point
      fill(0,0);
      ellipse(markerPos.x, markerPos.y, 120,120);
    }
  }
  
}