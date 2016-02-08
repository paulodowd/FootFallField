
// represents one person inferred from a series of feet, with a velocity so we can predict them

class Person
{
  final static int compatibleDistance = 80;
  
  float x;      // distance along the baseline left of the scanner in cm, probably between -200 and 200
  float y;      // distance away from the scanner baseline in cm, probably between 0 and 400
  int rotationCounter;
  int millis = -1;  // creation/update time in millis
  
  float vx = 0; // velocity in cm/mS
  float vy = 0;
  int steps;      // how many steps have we seen them take ? NB - we don't know the velovity if steps < 2
  
  Person( Reading foot )
  {
    steps = 1;
    setFromFoot( foot );
  }
  
  boolean consistentWith( Reading foot ) // might this foot be the next pave for this person ?
  {
    float d =  forecastDistanceFrom( foot );
    
    println(d);
    
    return d < compatibleDistance;
  }
  
  void newFoot( Reading foot ) // update this person on the assumption this is their next pace
  {
    steps += 1;
    
    if( steps >= 2 ) // with two steps we can work out the velocity
    {
      float newVx = (foot.x - x)/(foot.millis - millis);
      float newVy = (foot.y - y)/(foot.millis - millis);
      
      if( steps == 2 )
      {
        // first pace, velocity is just from 2 steps
        vx = newVx;
        vy = newVy;
      }
      else
      {
        // average with previous velocity to smooth out left/right step alternation
        //TODO - keep an array of feet, so we can always project off the last 3 ?
        //TODO - test with real feet, see idf side-to-side is really a problem
        vx = (vx + newVx)/2;
        vy = (vy + newVy)/2;
      }
    }
    setFromFoot( foot );
  }
  
  void setFromFoot( Reading foot ) 
  {
    x = foot.x;
    y = foot.y;
    rotationCounter = foot.rotationCounter;
    millis = foot.millis;
  }
  
  float xForecast (float futureMillis ) // what will their x be futureMillis into the future from right now ?
  {
    return x + vx * (futureMillis + millis() - millis);
  }
  
  float yForecast (float futureMillis )
  {
    return y + vy * (futureMillis + millis() - millis);
  }
  
  float distanceFrom( Reading foot )
  {
    return sqrt( (x-foot.x)* (x-foot.x) + (y-foot.y)*(y-foot.y) );
  }
  
  float forecastDistanceFrom( Reading foot ) // How far from our forecast location to this foot ?
  {
    int t = foot.millis - millis;
    float xf = xForecast(t);
    float yf = yForecast(t);
    
    return sqrt( (xf-foot.x)* (xf-foot.x) + (yf-foot.y)*(yf-foot.y) );
  }
}