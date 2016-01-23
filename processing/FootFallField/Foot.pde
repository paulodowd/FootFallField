
class Foot
{
  // Copy these three from foot_fall_field_lidar
  final static int MICROSTEPS = 8;
  final static int STEPS_PER_REV = 200;
  final static long ticksPerRev = MICROSTEPS * STEPS_PER_REV * 8;

  int range;  // lidar range in cm
  int tick;   // angle in the range 0 to ticksPerRev
  int x;      // distance along the baseline left of the scanner in cm, probably between -200 and 200
  int y;      // distance away from the scanner baseline in cm, probably between 0 and 400
  int millis;  // creation time in millis
  
  // Constructor for test feet
  Foot( int _x, int _y, int _millis )
  {
    x = _x;
    y = _y;
    millis = _millis;
  }
  
  // Constructor for real feet from lidar data
  Foot( int r, int t )
  {
    millis = millis();
    range = r;
    tick = t;
    
    float angle = TWO_PI * (float) tick / (float) ticksPerRev;
    x = (int) ((float) range * cos( angle )); //TODO - check convention and direciton of rotation
    y = (int) ((float) range * sin( angle ));
  }
}