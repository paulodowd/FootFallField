// Draw a grid deformed by the gravity of each foot

// with thatnks to http://www.openprocessing.org/sketch/1011

class GridPoint
{
  PVector origin, position;
  float toPlanetMult = 1000; // sets range
  float toOriginMult = 0.05;  // sets speed

  GridPoint(int x, int y)
  {
    origin = new PVector(x, y);
    position = new PVector(x, y);
  }

  void update(ArrayList<Reading> feet)
  {
 
    for (Reading foot : feet)
    {
      //Move towards targets[i]
      PVector screenPos = FootFallField.calibration.screenPosForReading( foot );
      
      PVector toTarget = PVector.sub(screenPos, position);
      
      float distToTarget = toTarget.mag();
      
      if (distToTarget > 0) 
        toTarget.limit(min(toPlanetMult/distToTarget, distToTarget));
      
      position.add(toTarget);
    }
    
    update();
  }
  
  void update()
  {
    //Move towards origin
    PVector toOrigin = PVector.sub(origin, position);
    float distToOrigin = toOrigin.mag();
    toOrigin.limit(distToOrigin*toOriginMult);

    position.add(toOrigin);
  }
    
}


class GravityEffect extends Effect
{
  GridPoint[][] points;
  int w, h;
  
  String imageName() { return "gravity.png"; }

GravityEffect()
  {
    this.w = 20;
    this.h = 20;
    points = new GridPoint[w][h];
    for (int y = 0; y < h; y++)
    {
      for (int x = 0; x < w; x++)
      {
        int sx = (int)map(x, 0, w - 1, 0, width - 1),
            sy = (int)map(y, 0, h - 1, 0, height - 1);
        points[x][y] = new GridPoint(sx, sy);
      }
    }
  }

  void draw(ArrayList<Reading> readings, ArrayList<Reading> feet, ArrayList<Person> people)
  {

    synchronized( feet )  
    {
      update( feet );
      //drawDots();
      drawGrid();
    } 


   
    
  }
  
  void update(ArrayList<Reading> feet)
  {
    for (int y = 0; y < h; y++)
    {
      for (int x = 0; x < w; x++)
      {
        points[x][y].update(feet);
      }
    }
  }
  
  void drawDots()
  {

    noStroke();
      rectMode(CENTER);
    fill(color(0, 255, 0));

    //Draw horizontal lines
    for (int y = 0; y < h; y++)
    {
      for (int x = 0; x < w; x++)
      {
        PVector p = points[x][y].position;
        rect(p.x, p.y, 20, 20);
        
      }
    }
    

    
  }
  
  void drawGrid()
  {

    noFill();
    strokeWeight(10);
    stroke(color(0, 255, 0));
    
    //Draw horizontal lines
    for (int y = 0; y < h; y++)
    {
      beginShape();
      for (int x = 0; x < w; x++)
      {
        PVector p = points[x][y].position;
        vertex(p.x, p.y);
      }
      endShape();
    }
    
    //Draw vertical lines
    for (int x = 0; x < w; x++)
    {
      beginShape();
      for (int y = 0; y < h; y++)
      {
        PVector p = points[x][y].position;
        vertex(p.x, p.y);
      }
      endShape();
    }
    
  }
   
}