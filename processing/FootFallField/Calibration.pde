
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
  
  ArrayList<CalibrationPoint> points;
  
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
  
  PVector screenPosForReading( Reading reading )
  {
    return screenPosForXY( reading.x, reading.y );
   
  }
  
  PVector screenPosForXYUncalibrated( int x, int y ) // x,y in cm from sensor
  {
    int sx = (screenWidth * x)/lidarWidth + screenWidth/2;  // assume lidar is in the middle of the bottom edge of the screen
    int sy = screenHeight - (screenHeight * y)/lidarDepth;
    
    PVector screenPos = new PVector(sx, sy);
    
    return screenPos;
  }
  
  void setPoints( ArrayList<CalibrationPoint> _points )
  {
    points = _points;
    
  }
  
  boolean isCalibrated()
  {
    if( points == null || points.size() != 4 )  // no calibration data yet
      return false;
      
    return true;
  }
  
  PVector screenPosForXY( int px, int py )
  {
    if( points == null || points.size() != 4 )  // no calibration data yet
      return screenPosForXYUncalibrated( px, py ); // just so we can draw something
      
    Reading a = points.get(0).foot;
    Reading b = points.get(1).foot;
    Reading c = points.get(2).foot;
    Reading d = points.get(3).foot;
    
    double C = (double)(a.y - py) * (d.x - px) - (double)(a.x - px) * (d.y - py);
      double B = (double)(a.y - py) * (c.x - d.x) + (double)(b.y - a.y) * (d.x - px) - (double)(a.x - px) * (c.y - d.y) - (double)(b.x - a.x) * (d.y - py);
      double A = (double)(b.y - a.y) * (c.x - d.x) - (double)(b.x - a.x) * (c.y - d.y);

      double D = B * B - 4 * A * C;

      double u = (-B - Math.sqrt(D)) / (2 * A);

      double p1x = a.x + (b.x - a.x) * u;
      double p2x = d.x + (c.x - d.x) * u;
      

      double v = (px - p1x) / (p2x - p1x);
      
      // u and v are normalised so 0->1 maps to the side of the rectangle
      // now calculate the screen coordinates for p
      
      double sx = a.x + u * (b.x - a.x);
      double sy = a.y + v * (c.y - a.y);
      
      return new PVector( (int) sx, (int) sy );
      
    
  }

  /*
  from
  http://www.gamedev.net/topic/596392-uv-coordinate-on-a-2d-quadrilateral/page-1#entry4779072
  
  Given the coordinates a, b, c, d, and p, how would I find the normalized UV coordinates of p? (For example, to sample a texture at that point.)

  a, b, c, d, and p are 2D (that is, only X,Y coordinates). p will always be inside abcd.

  We have four CalibrationPoints, representing a rectangle in projector-space and a quadrilateral in lidar-space
  
  We want to be able to convert points in lidar-space into points in projector-space, so we can project a marker onto the corresponding foot
  So, the maths here converts p (in lidar-space) into a normalised position in the rectangle, we just need to multiply it up by the rectangle size to convert it to screen space.
  I think.
  
  
  double C = (double)(a.Y - p.Y) * (d.X - p.X) - (double)(a.X - p.X) * (d.Y - p.Y);
      double B = (double)(a.Y - p.Y) * (c.X - d.X) + (double)(b.Y - a.Y) * (d.X - p.X) - (double)(a.X - p.X) * (c.Y - d.Y) - (double)(b.X - a.X) * (d.Y - p.Y);
      double A = (double)(b.Y - a.Y) * (c.X - d.X) - (double)(b.X - a.X) * (c.Y - d.Y);

      double D = B * B - 4 * A * C;

      double u = (-B - Math.Sqrt(D)) / (2 * A);

      double p1x = a.X + (b.X - a.X) * u;
      double p2x = d.X + (c.X - d.X) * u;
      double px = p.X;

      double v = (px - p1x) / (p2x - p1x);
 */ 
}