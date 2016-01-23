
// Converts between Foot coordinates and window coordinates, must be set up at runtime to align lidar objects with projected image

// TODO - needs to be set up by a calibration effect that displays markers near the corners to be stood on

class Calibration
{
  // Assume a 4m square working area for now
  final static int lidarWidth = 400;
  final static int lidarDepth = 400;
  
  int screenWidth;
  int screenHeight;
  
  Calibration( int w, int h )
  {
    screenWidth = w;
    screenHeight = h;
  }
  
  int maxLidarX()
  {
    return lidarWidth/2;
  }
  
  int minLidarX()
  {
    return - lidarWidth/2;
  }
  
  PVector screenPosForFoot( Foot foot )
  {
    int sx = (screenWidth * foot.x)/lidarWidth + screenWidth/2;  // assume lidar is in the middle of the bottom edge of the screen
    int sy = screenHeight - (screenHeight * foot.y)/lidarDepth;
    
    PVector screenPos = new PVector(sx, sy);
    
    return screenPos;
  }
}