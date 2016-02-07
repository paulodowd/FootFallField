
// Draw a blob for each Foot

class BlobEffect implements Effect
{
    void start()
    {

      //noStroke();
    }
    
    
  void draw(ArrayList<Reading> readings, ArrayList<Reading> feet, ArrayList<Person> people)
  {

    PVector lidarPos = FootFallField.calibration.screenPosForXY(0,0);
    
     strokeWeight(5);
    
    if( people != null )
    {
      synchronized( people )  
      {
        for( Person person : people)
        {
      
          
          PVector screenPos = FootFallField.calibration.screenPosForXY( person.x, person.y );
          {
            // Draw the person as a big hollow circle
            stroke(200);
            fill(0);
            ellipse(screenPos.x, screenPos.y, 100,100);
            
            // And draw a grey circle to show their forecast position
            PVector vectorPos = FootFallField.calibration.screenPosForXY( person.xForecast(0), person.yForecast(0) );
            line(screenPos.x, screenPos.y,vectorPos.x, vectorPos.y);
            stroke(100);
            noFill();
            ellipse(vectorPos.x, vectorPos.y, 100,100);
  
            // and a big pale circle to show the acceptable next-step positions
            noStroke();
            fill(100, 100, 200, 65);
            //fill(153);
            float radius = FootFallField.calibration.screenDistanceNear(person.xForecast(0), person.yForecast(0),Person.compatibleDistance);
            ellipse(vectorPos.x, vectorPos.y, radius*2,radius*2);
     
          }
        }
      }
    }
    
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