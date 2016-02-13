// Draw a random circle
// if jumped / clicked on, draw another

class Splat
{
  float x,y,d,sw,sr,sg,sb,sa;
  //x: center X coordinate
  //y: center Y coordinate
  //d: diameter
  //sw: stroke weight
  //sr: stroke color R
  //sg: stroke color G
  //sb: stroke color B
  //sa: stroke color alpha
  Splat (float x_in,float y_in,float d_in,float sw_in,float sr_in,float sg_in,float sb_in,float sa_in)
  { x=x_in; y=y_in; d=d_in; sw=sw_in; sr=sr_in; sg=sg_in; sb=sb_in; sa=sa_in;}
}


class SplatEffect extends Effect
{
  ArrayList<Splat> splats = new ArrayList<Splat>();
  
  String imageName() { return "splat.png"; }

  void draw(ArrayList<Reading> readings, ArrayList<Reading> feet, ArrayList<Person> people)
  {
 
    noFill();

    synchronized( splats )  
    {
      for( int i = 0; i < splats.size();  )
      {
        Splat splat = splats.get(i);
        //just continue to render
        //println("rendering splat "+i+" at "+splat.x+" "+splat.y+" "+splat.d+" R "+splat.sr+" G "+splat.sg+" B "+splat.sb+" A "+splat.sa);    
        strokeWeight(splat.sw);
        //fill(255,0);
        stroke(splat.sr, splat.sg, splat.sb, splat.sa);
        ellipse(splat.x, splat.y, splat.d, splat.d);           
      }
    } 
    
  }
  
    void notifyNewFoot( Reading foot )
    {
      
      PVector screenPos = FootFallField.calibration.screenPosForReading( foot ); //<>//
      if(splats.size() == 0){
          int x = int(random(0, width));
          int y = int(random(0, height));
          splats.add( new Splat(x,y,20,30,int(random(0,255)),int(random(0,255)),int(random(0,255)),250)); 
          println("making splat at "+x+" "+y);
      }else{
        synchronized( splats )  
        {
          for( int i = 0; i < splats.size();  )
          {
          Splat splat = splats.get(i);
          //if position is within the splat, remove it and generate a new one
            //println("screen pos "+screenPos.x+" greater than "+(splat.x + splat.d));
            if(screenPos.x > (splat.x + splat.d)  && screenPos.x > (splat.x - splat.d) && 
              screenPos.y > splat.y + splat.y && screenPos.y > splat.y - splat.d ){
              splats.remove(i);
            }else{ 
              int x = int(random(0, width));
              int y = int(random(0, height));
              //just make a random one? will this work?
              splats.add( new Splat(x,y,20,30,int(random(0,255)),int(random(0,255)),int(random(0,255)),250));
            }
          }
        }
      }
      
   }
}