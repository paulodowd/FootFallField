// Represents one lidar reading, with range and angle
class Reading
{
  // Copy these three from foot_fall_field_lidar
  final static int MICROSTEPS = 8;
  final static int STEPS_PER_REV = 200;
  final static long ticksPerRev = MICROSTEPS * STEPS_PER_REV * 8;

  int range;  // lidar range in cm
  int tick;   // angle in the range 0 to ticksPerRev/2, in other words 0 to 6400
  
  float x;      // distance along the baseline left of the scanner in cm, probably between -200 and 200
  float y;      // distance away from the scanner baseline in cm, probably between 0 and 400
  int millis;  // creation time in millis
  int rotationCounter; // which rotation did we see this foot on ?
  boolean isBackground; // do we think this foot is past the background, so should be ignored ?
  
  // Constructor for test Reading
  Reading( int _x, int _y, int _millis, int _rotationCounter )
  {
    x = _x;
    y = _y;
    millis = _millis;
    rotationCounter = _rotationCounter;
    isBackground = false;
  }
  
  // Constructor for real Reading from lidar data
  Reading( int r, int t, int _rotationCounter )
  {
    millis = millis();
    range = r;
    tick = t;
    rotationCounter = _rotationCounter;
    isBackground = false;
    
    float angle = angle();
    x = (int) ((float) range * - cos( angle ));
    y = (int) ((float) range * sin( angle ));
  }
  
  float angle() // in radians
  {
    float angle = TWO_PI * (float) tick / (float) ticksPerRev;
    return angle;
  }
  
  void printDiag()
  {
    println("Foot:");
    print("  range ");
    println( range );
    print("  tick ");
    println( tick );

    print("  x ");
    println( x );
    print("  y ");
    println( y );
    
  }
}