// represents one object, probably a foot
// inferred from a run of lidar readings at simialr ranges

class Foot
{
    int x;      // distance along the baseline left of the scanner in cm, probably between -200 and 200
  int y;      // distance away from the scanner baseline in cm, probably between 0 and 400
  int millis;  // creation time in millis
  int rotationCounter; // which rotation did we see this foot on ?

  Foot( int _x, int _y, int _millis, int _rotationCounter )
  {
    x = _x;
    y = _y;
    millis = _millis;
    rotationCounter = _rotationCounter;
  }
}