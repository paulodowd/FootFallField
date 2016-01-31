
// Converts between Foot coordinates and window coordinates, must be set up at runtime to align lidar objects with projected image

// TODO - needs to be set up by a calibration effect that displays markers near the corners to be stood on

class Calibration
{
  // Assume a 4m square working area for now.
  // Scanner is in the middle of the bottom edge of the square at 0,0
  // Area extend from x = -200 (left) to x = +200 (right), y = 0 to 400
  
  final static int lidarWidth = 300;
  final static int lidarDepth = 300;
  
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
    return screenPosForXY( foot.x, foot.y );
   
  }
  
   PVector screenPosForXY( int x, int y ) // x,y in cm from sensor
  {
    int sx = (screenWidth * x)/lidarWidth + screenWidth/2;  // assume lidar is in the middle of the bottom edge of the screen
    int sy = screenHeight - (screenHeight * y)/lidarDepth;
    
    PVector screenPos = new PVector(sx, sy);
    
    return screenPos;
  }
}