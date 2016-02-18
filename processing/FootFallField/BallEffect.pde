// http://www.openprocessing.org/sketch/67284

class Ball
{
  float x,y,d,sw,sr,sg,sb,sa,xh,yh,sp_x,sp_y;
  //x: center X coordinate
  //y: center Y coordinate
  //d: diameter
  //sw: stroke weight
  //sr: stroke color R
  //sg: stroke color G
  //sb: stroke color B
  //sa: stroke color alpha
  
  Ball (float x_in,float y_in,float d_in,float sw_in,float sr_in,float sg_in,float sb_in,float sa_in, float xh_in, float yh_in,float sp_x_in, float sp_y_in)
  { x=x_in; y=y_in; d=d_in; sw=sw_in; sr=sr_in; sg=sg_in; sb=sb_in; sa=sa_in; xh=xh_in; yh=yh_in; sp_x=sp_x_in;sp_y=sp_y_in;}
}


class BallEffect extends Effect
{

  Ball ball = new Ball(0,0,20,30,255,255,0, 250, 90.0, 90.0, 7.0, 7.0);
  String imageName() { return "ball.png"; }
  void draw(ArrayList<Reading> readings, ArrayList<Reading> feet, ArrayList<Person> people)
  {
 
    noFill();
    ellipseMode(CORNER);
    strokeWeight(ball.sw);
    stroke(ball.sr, ball.sg, ball.sb, ball.sa);
    fill(ball.sr, ball.sg, ball.sb);
    //draw the circle in its current position
    ellipse(ball.x, ball.y, ball.xh, ball.yh);
  
    //add a little gravity to the speed
    //ball.sp = ball.sp + 0.5; 
   
    //add speed to the ball
    ball.y = ball.y + ball.sp_y;
    ball.x = ball.x + ball.sp_x;  

    if (ball.y >= height) {
       // if the ball hits the bottom, bounce
       ball.sp_y = -ball.sp_y * random(0.8, 1.2);     
    }
    if (ball.y <= 0) {
      // if the ball hits the top, bounce
      ball.sp_y = -ball.sp_y * random(0.8, 1.2);
    }
    
    if (ball.x >= width) {
      //if the ball hits the right, bounce
       ball.sp_x = -ball.sp_x;     
    }
    
    if (ball.x <= 0) {
      //if the ball hits the left, bounce
      ball.sp_x = -ball.sp_x;
    }
    
  }
  
    void notifyNewFoot( Reading foot )
    {
      
      PVector screenPos = FootFallField.calibration.screenPosForReading( foot );
      if (screenPos.y < (ball.y + ball.yh) && screenPos.y > (ball.y - ball.yh)
         && screenPos.x < (ball.x + ball.xh)  && screenPos.x > (ball.x - ball.xh) ) {
         // if the ball hits the foot, bounce
         ball.sp_y = -ball.sp_y * random(0.8, 1.2);
         ball.sp_x = -ball.sp_x * random(0.8, 1.2);
      }

/*
        //if ball position is within the splat, bounce it
        if(screenPos.x < (ball.x + ball.h)  && screenPos.x > (ball.x - ball.h) && 
                screenPos.y < (ball.y + ball.h) && screenPos.y > (ball.y - ball.h) ){
              //println("HIT!");
              splats.remove(i);
         }
*/
  }
}