
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
      // clear to hide old blobs
      fill( 0 );
      rect( 0,0, width, height );
      
      
    for( Foot foot : FootFallField.feet)
    {
  
      fill(255);
      
      PVector screenPos = FootFallField.calibration.screenPosForFoot( foot );
      ellipse(screenPos.x, screenPos.y, 20, 20);
    }
    
  }
}