
// Draw a blob for each Foot

class BlobEffect implements Effect
{
    void start()
    {
      background(0);
noStroke();
    }
  void draw()
  {
    for( Foot foot : foot_fall_field.feet)
    {
      fill(255);
      
      PVector screenPos = Calibration.screenPosForFoot( foot );
      ellipse(screenPos.x, screenPos.y, 20, 20);
    }
    
  }
}