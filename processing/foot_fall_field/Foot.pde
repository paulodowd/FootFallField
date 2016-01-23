
class Foot
{
  // Copy these three from foot_fall_field_lidar
  final static int MICROSTEPS = 8;
  final static int STEPS_PER_REV = 200;
  final static long ticksPerRev = MICROSTEPS * STEPS_PER_REV * 8;

  int range;  // lidar range in cm
  int tick;   // angle in the range 0 to ticksPerRev
  int x;      // distance along the baseline left of the scanner in cm
  int y;      // distance away from the scanner baseline in cm
}