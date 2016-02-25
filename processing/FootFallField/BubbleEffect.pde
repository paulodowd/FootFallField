//bubbles into each footfall
class Bubble
{
  float x,y,d,sw,sr,sg,sb,sa,xh,yh,sp_x,sp_y, x_goal, y_goal;
  //x: center X coordinate
  //y: center Y coordinate
  //d: diameter
  //sw: stroke weight
  //sr: stroke color R
  //sg: stroke color G
  //sb: stroke color B
  //sa: stroke color alpha
  //x_goal, y_goal: a foot to aim for

  Bubble (float x_in,float y_in,float d_in,float sw_in,float sr_in,float sg_in,float sb_in,float sa_in, float xh_in, float yh_in,float sp_x_in, float sp_y_in, float x_goal_in, float y_goal_in)
  { x=x_in; y=y_in; d=d_in; sw=sw_in; sr=sr_in; sg=sg_in; sb=sb_in; sa=sa_in; xh=xh_in; yh=yh_in; sp_x=sp_x_in;sp_y=sp_y_in; x_goal=x_goal_in;y_goal=y_goal_in ;}

}


class BubbleEffect extends Effect
{
  float diaIncreaseRate = 6; //diameter increasing rate
  float strokeDecreaseRate = 0.3; //stroke weight decreasing rate

  ArrayList<Bubble> bubbles = new ArrayList<Bubble>();
  
  String imageName() { return "bubble.png"; }

  void draw(ArrayList<Reading> readings, ArrayList<Reading> feet, ArrayList<Person> people)
  {
    noFill();
    
    synchronized( bubbles )  
    {
      for( int i = 0; i < bubbles.size();  )
      {
        Bubble bubble = bubbles.get(i);
        
      if (bubble.y_goal < (bubble.y + bubble.yh) && bubble.y_goal > (bubble.y - bubble.yh)
         && bubble.x_goal < (bubble.x + bubble.xh)  && bubble.x_goal > (bubble.x - bubble.xh) ) {
           // you have reached your destination  
           bubbles.remove(i);
        }else{
          // head towards X and Y
          if(bubble.x > bubble.x_goal){
              bubble.x = bubble.x - 20;
          }else{
              bubble.x = bubble.x + 20;
          }
          if(bubble.y > bubble.y_goal){
              bubble.y = bubble.y - 20;
          }else{
              bubble.y = bubble.y + 20;
          }      
          stroke(bubble.sr, bubble.sg, bubble.sb, bubble.sa);
          fill(bubble.sr, bubble.sg, bubble.sb, 127);
          //draw the circle in its current position
          ellipse(bubble.x, bubble.y, bubble.xh, bubble.yh);
      
        }
        
        i ++;
      }
    } 

    
  }
  
    void notifyNewFoot( Reading foot )
    {
      PVector screenPos = FootFallField.calibration.screenPosForReading( foot ); //<>//
      synchronized( bubbles )  
      {
        
        float d1 = random(20,90);
        float d2 = random(20,90);
        float d3 = random(20,90);
        float d4 = random(20,90);
        bubbles.add( new Bubble(0,0,d1,30,255,255,255, 10, d1, d1, 7.0, 7.0, screenPos.x,screenPos.y));
        bubbles.add( new Bubble(width,height,d2,30,255,255,255, 10, d2, d2, 7.0, 7.0, screenPos.x,screenPos.y));
        bubbles.add( new Bubble(0,height,d3,30,255,255,255, 10, d3, d3, 7.0, 7.0, screenPos.x,screenPos.y));
        bubbles.add( new Bubble(width,0,d4,30,255,255,255, 10, d4, d4, 7.0, 7.0, screenPos.x,screenPos.y));
      }
 
    }
}