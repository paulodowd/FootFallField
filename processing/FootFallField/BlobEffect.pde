
// Draw a blob for each Foot

class BlobEffect implements Effect
{
    void start()
    {
      background(0);
      stroke(60);
      //noStroke();
    }
    
    
  void draw(ArrayList<Reading> readings)
  {
      // clear to hide old blobs
      fill( 0 );
      rect( 0,0, width, height );
      
      fill(255);
      stroke(60);
      
    synchronized( readings )  
    {
    for( Reading reading : readings)
    {
  
      
      PVector screenPos = FootFallField.calibration.screenPosForReading( reading );
      if( reading.isBackground )
      {  
        fill(64);
        ellipse(screenPos.x, screenPos.y, 10,10);
      }
      else
      {
        fill(255);
        ellipse(screenPos.x, screenPos.y, 20, 20);
        line(screenPos.x, screenPos.y,width/2, height);
      }
    }
    }
  }
}