// manages maintaining the distance to the fixed background, so we can ignore it better

class Background
{
  final static int backgroundSegments = 90; // number of segments of background range we'll accumulate over the 180 degrees of scan
  int backgroundRangeAtAngle[];             // The rolling-average range as a function of angle
  final static int backgroundSamples = 1000; // number of samples we'll rolling-average over
  
  
  Background()
  {

    backgroundRangeAtAngle = new int[backgroundSegments];
    for( int i =0; i < backgroundSegments; i ++ )
      backgroundRangeAtAngle[i] = -1;
    
  }
  
  void draw()
{
  fill(204, 102, 0);
  for( int i =0; i < backgroundSegments; i ++ )
      if( backgroundRangeAtAngle[i] != -1 )
      {
        float angle = ((float)i * PI ) / backgroundSegments;
        
        int x = (int) ((float) backgroundRangeAtAngle[i] * - cos( angle )); 
        int y = (int) ((float) backgroundRangeAtAngle[i] * sin( angle ));
        
        PVector screenPos = FootFallField.calibration. screenPosForXY( x, y );
        ellipse(screenPos.x, screenPos.y, 10, 10);
      }
}

void accumulateBackground( Reading reading )
{
  int segment = (int) ((reading.angle() * backgroundSegments) / PI);
  
  if( segment >=0 && segment < backgroundSegments )
  {
    if( backgroundRangeAtAngle[segment] == -1 )
      backgroundRangeAtAngle[segment] = reading.range;  // initialise to the first reading
    else
      backgroundRangeAtAngle[segment] = (int) (((float)backgroundRangeAtAngle[segment] * (float)(backgroundSamples -1) + (float)reading.range)/(float)backgroundSamples); // rolling average
  }
}

boolean isPastBackground( Reading reading ) // do we think this foot is as far away as our fixed background ?
{
  int segment = (int) ((reading.angle() * backgroundSegments) / PI);
  
  if( segment >=0 && segment < backgroundSegments )
    if( backgroundRangeAtAngle[segment] != -1 )
      if( reading.range > backgroundRangeAtAngle[segment] - 20 )
        return true;
        
  return false;
}

}