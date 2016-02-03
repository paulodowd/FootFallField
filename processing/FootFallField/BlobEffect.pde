
// Draw a blob for each Foot

class BlobEffect implements Effect
{
    void start()
    {

      //noStroke();
    }
    
    
  void draw(ArrayList<Reading> readings, ArrayList<Reading> feet)
  {

    PVector lidarPos = FootFallField.calibration.screenPosForXY(0,0);
    
    strokeWeight(2);
    
    if( feet != null )
    {
      synchronized( feet )  
      {
        for( Reading reading : feet)
        {
      
          
          PVector screenPos = FootFallField.calibration.screenPosForReading( reading );
          {
            stroke(60);
            fill(100, 200, 0);
            ellipse(screenPos.x, screenPos.y, 40, 40);
            line(screenPos.x, screenPos.y,lidarPos.x, lidarPos.y);
     
          }
        }
      }
    }
    
    if( readings != null )
    {
      synchronized( readings )  
      {
        strokeWeight(2);
        
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
}