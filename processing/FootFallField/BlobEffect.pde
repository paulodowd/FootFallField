
// Draw a blob for each Foot

class BlobEffect implements Effect
{
    void start()
    {
      background(0);
      stroke(60);
      //noStroke();
    }
    
    
  void draw(ArrayList<Reading> readings, ArrayList<Reading> feet)
  {
      // clear to hide old blobs
      fill( 0 );
      rect( 0,0, width, height );
      

      
      
    synchronized( feet )  
    {
      for( Reading reading : feet)
      {
    
        
        PVector screenPos = FootFallField.calibration.screenPosForReading( reading );
        {
          stroke(60);
          fill(100, 200, 0);
          ellipse(screenPos.x, screenPos.y, 40, 40);
          line(screenPos.x, screenPos.y,width/2, height);
   
        }
      }
    }
    
    synchronized( readings )  
    {
      for( Reading reading : readings)
      {
    
        
        PVector screenPos = FootFallField.calibration.screenPosForReading( reading );
        if( reading.isBackground )
        {  
          stroke(255); // white outline circle
          fill(64);
          ellipse(screenPos.x, screenPos.y, 10,10);
        }
        else
        {
          stroke(255); // white outline circle
          fill(0,0);
          ellipse(screenPos.x, screenPos.y, 20, 20);
          //line(screenPos.x, screenPos.y,width/2, height);
        }
      }
    }
    
    
  }
}