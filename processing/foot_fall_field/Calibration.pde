// Converts between Foot coordinates and window coordinates, must be set up at runtime to align lidar objects with projectyed image
class Calibration
{
  final static int lidarWidth = 400;
  final static int lidarDepth = 400;
  
  int screenWidth;
  int screenHeight;
  
  Calibration( int w, int h )
  {
    screenWidth = w;
    screenHeight = h;
  }
  
  PVector screenPosForFoot( Foot foot )
  {
    int sx = (screenWidth * foot.x)/lidarWidth + screenWidth/2;  // assume lidar is in the middle of the bottom edge of the screen
    int sy = screenHeight - (screenHeight * foot.y)/lidarHeight;
    
    PVector screenPos = new PVector(sx, sy);
    
    return screenPos;
  }
}