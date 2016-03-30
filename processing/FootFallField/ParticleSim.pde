
// A simulation of particles which respond to foot fall
// Uses a KD-Tree data structure to perform inter-particle collision
// detection.
// KD-Tree searches for nearest neighbour by dividing the 2D space in
// half each time a branch is made, cutting the search space in half 
// each time.  Using KD-Tree we make only 1 collision detection per
// particle, rather than every particle against every other particle.
// Collision detection is expensive because of dist().

class ParticleSimEffect extends Effect {
  
  final float FOOTFALL_RADIUS = 100;
  final int MAX_PARTICLES = 2000; 
  final float FRICTION_GAIN = 0.92;  // closer to 1, less friction
  final long FOOTFALL_TIMEOUT = 1000; //milli seconds.
  
  Particle_c particles[];  // Particles
  KdTree_c kd_tree;        // KD tree.
  
  long footfall_time;      // timeout when a footfall is received.
  PVector footfall;        // Pvector, Nulled when timeout.
  
  ParticleSimEffect() {
    int i;
    
    // Once - create all the particles.
    particles = new Particle_c[ MAX_PARTICLES ];
  
    // Create n number of particles, pass unique id. 
    // Unique ID so they don't collide with self.
    for ( i = 0; i < MAX_PARTICLES; i++ ) particles[i] = new Particle_c( i );
    
    // Init footfall timeout.
    footfall_time = millis();
    
  }
  
  void draw(ArrayList<Reading> readings, ArrayList<Reading> feet, ArrayList<Person> people) {
     int i;
    
    // points for quicksort, smaller class than Particle_c
    // used for arraycopy during quicksorting.
    Point[] points; 
    
    // Init the small points class array to match particles.
    // Copies x,y and id.
    points = new Point[ MAX_PARTICLES ];
    for( i = 0; i < MAX_PARTICLES; i++ ) {
       points[i] = new Point( particles[i].position.x, particles[i].position.y, i );
    }
    
    // Build the tree from points.
    kd_tree = new KdTree_c( points );
  
  
  
    // Each particle updates.
    // Looks up nearest neighbour in KD tree.
    // Performs collision detection.
    // Also does boundary checks.
    // And footfall check.
    for ( Particle_c p : particles ) p.update( );
  
    // Expire footfall.
    if( (millis() - footfall_time) > FOOTFALL_TIMEOUT ) footfall = null;
  
  
  }
  
  void notifyNewFoot( Reading foot )
    {
      footfall_time = millis();
      this.footfall = FootFallField.calibration.screenPosForReading( foot );
      
    }
    
  
  

class Point {
   float x,y,dx,dy;
   int id;
   Point( float x, float y) {
      this.x = x;
      this.y = y;
      id = -1;
   } 
   Point( float x, float y, int id ) {
      this.x = x;
      this.y = y;
      this.id = id;
   }
}

final Point[] copy(final Point[] src, final int a, final int b) {
    final Point[] dst = new Point[b-a];
    
    // System does not work with processing.js
    //System.arraycopy(src, a, dst, 0, dst.length);
    
    arrayCopy( src, a, dst, 0, dst.length );
    
    return dst;
}


// Class for each node of the tree
class Node_c {
  int depth;
  Point pnt;
  Node_c L, R;
    
  Node_c( int depth ) {
     this.depth = depth; 
  }
  boolean isLeaf() {
     return (L==null) | (R==null);  
  }
}

class KdTree_c {
   int max_depth = 0;
   Node_c root;
  
   KdTree_c( Point[] points ) {
      
     max_depth = (int)Math.ceil( Math.log( points.length) / Math.log(2) );
     root = new Node_c(0);
     build( root, points );
   } 
  
   void build( final Node_c node, final Point[] points ) {
  
     
     final int e = points.length;
     final int m = e >> 1;  // bitwise divide by 2
     
     // Class that handles quicksorting.
     final Quicksort quick_sort = new Quicksort();
     
     // Insure half is less than 1, therefore m > 1
     if( e > 1 ) {
          int depth = node.depth;
          
          // Array, (depth&1) tells us if it is odd or even layer
          // This is used to quicksort the array by either x or y
          // coordiantes.
          // Therefore, layer 0 sorts x, layer 1 sorts y,
          // lyaer 2 sorts x, layer 3 sorts y... etc
          quick_sort.sort( points, (depth & 1) );
          
          // Set the left and right node up.
          // Note, we set the left and move up a layer
          // in the tree.
          node.L = new Node_c( depth );
          depth++;
          node.R = new Node_c( depth );
          
          // Recursive call, sending the first half of
          // the original array left and the second half
          // of the original array right.
          // Therefore, each call of this function divides
          // the dataset by 2, so it gets quicker each time.
          build( node.L, copy( points, 0, m ));
          build( node.R, copy( points, m, e ));
       }
       
       // This sets the current node to the middle array
       // value.  Bcause this is a recursive function, this
       // is the middle array value for each call, all the way 
       // back to the root node.  
       node.pnt = points[m];
   }
   
  void draw() {
     drawPoints( root ); 
     
     NN nn = getNN( new Point(mouseX, mouseY) );
     stroke(255,0,0);
     line( nn.pnt_in.x, nn.pnt_in.y, nn.pnt_nn.x, nn.pnt_nn.y );
  }
  
  
  
  int getNNIndex( Point pt_in ) {
     NN nn = getNN( pt_in );
     if( nn.pnt_nn != null ) return nn.pnt_nn.id;
     
     return -1;
  }
   
  // Recursive drawing.
  void drawPoints( Node_c node) {
    if ( node.isLeaf() ) {
      strokeWeight(1);
      stroke(0); 
      fill(0, 165, 255);
      ellipse(node.pnt.x, node.pnt.y, 4, 4);
    } else {
      drawPoints( node.L );
      drawPoints( node.R );
    }
  }
   
   
   public class NN {
      Point pnt_in = null;
      Point pnt_nn = null;
      
      // No Float.MAX_VALUE in processing.js
      //float min_sq = Float.MAX_VALUE;
      float min_sq = MAX_FLOAT;
      
      public NN(Point pnt_in) {
        this.pnt_in = pnt_in;
      }

      void update(Node_c node) {

        float dx = node.pnt.x - pnt_in.x;
        float dy = node.pnt.y - pnt_in.y;
        float cur_sq = dx*dx + dy*dy;

        if ( cur_sq < min_sq ) {
          min_sq = cur_sq;
          pnt_nn = node.pnt;
        }
      }
  }

  // getNN(Point)
  // if only a point is passed in, then we generate
  // a NN object, and the call getNN( nn, root), passing
  // the root node, leading to the tree navigation
  public NN getNN(Point point) {
    NN nn = new NN(point);
    getNN(nn, root);
    return nn;
  }

  public NN getNN(NN nn, boolean reset_min_sq) {
    if (reset_min_sq) nn.min_sq = Float.MAX_VALUE;
    getNN(nn, root);
    return nn;
  }

  private void getNN(NN nn, Node_c node) {
    
    if( node.pnt.id == nn.pnt_in.id ) {
       return;
    } else if ( node.isLeaf() ) {  // End of tree structure
      nn.update(node);
    } else {
      
      // PlaneDistance compares two points and tells you
      // if one is to the left of the other on either
      // x or y axis (determined using odd or even layer
      // number, same rule as when building tree)
      // Negative means left, positive means right
      float dist_hp = planeDistance(node, nn.pnt_in);

      // check the half-space, the point is in.
      // Call this function again, but passing the 
      // next node to check against.
      getNN(nn, (dist_hp < 0) ? node.L : node.R);

      // check the other half-space when the current distance (to the
      // nearest-neighbor found so far) is greater, than the distance
      // to the other (yet unchecked) half-space's plane.
      if ( (dist_hp*dist_hp) < nn.min_sq ) {
        getNN(nn, (dist_hp < 0) ? node.R : node.L);
      }
    }
  }

  private final float planeDistance( Node_c node, Point point) {
    
    // Check if the layer number is odd or even,
    // and use the same rule for x or y search 
    // association.  
    if ( (node.depth & 1) == 0) {
      return point.x - node.pnt.x;
    } else {
      return point.y - node.pnt.y;
    }
  }
   
   

}


// A class which represents a particle in 2D space and takes care of
// all it's own colisions and dynamics.  
class Particle_c {
  PVector position;
  PVector velocity;
  int id;
  float r, m;
  color c1 = color( random(100,255 ) );
  color c2 = c1;
  // Variables required to track the rate of collision
  // this particle is experiencing.
  float p_collision;  // probability between 0.1 and 1
  float t_collision;  // time of last collision.
  
  // Constructor, id required to check against self-collision later.
  Particle_c( int _id ) {
     position = new PVector( random(0,width), random(0,height) );
     velocity = new PVector();
     //velocity = PVector.random2D();
     //velocity.mult(3);
     
     r = random(0.5,3);
     m = r *  0.1;
     id = _id;
     
     p_collision = 1;
     t_collision = millis();
  }

  

  // This one function follows an update procedure and completes
  // all steps to draw to the screen.
  void update() {
    
    //if( id == 0 ) println("p_collision: " + p_collision );
    
    // Defines a new velocity if collision occurs.
    checkCollisionWithOthersKDTree();
    
    // Modifies velocity against window border
    checkBoundaryCollision();
    
    // Modifies velocity with respect to mouse click.
    //checkAgainstMouse();
    
    // Check against the last footfall.
    checkAgainstFootfall();
    
    // Slowly reduces any velocity to zero.
    applyFriction();
    
    // Apply velocity for this update cycle.
    position.add(velocity);
    
    // Draw to screen.
    display();
  }
  
  void checkAgainstFootfall() {
    
    
     if( footfall != null ) {
       // Distance between object and footfall.
       float d = PVector.dist( position, footfall );
       // CHeck if in radius.
       if( d < FOOTFALL_RADIUS ) { 
         
         // Subtract vectors to get a vector from origin (0,0)
         PVector bVect = PVector.sub( footfall, position );
         
         float theta;
         theta = atan2( footfall.y - position.y, footfall.x - position.x );
         
         // Inverse d, so that the further from the mouse,
         // the slower the additional velocity away. 
         d = FOOTFALL_RADIUS - d;
         velocity.x -= ( d * cos( theta) ) *  0.02;
         velocity.y -= ( d * sin( theta) ) *  0.02;
       }
     }
  }
  
  // When the mouse is clicked, this object will check if it is
  // a radius of influence (100) and if so, moves away by adding
  // a distance proportional velocity.  
  void checkAgainstMouse() {
    
    if( mousePressed == true ) {
      
       // Mouse vector.
       PVector mVect = new PVector( mouseX, mouseY );
       
       // Distance between object and mouse.
       float d = PVector.dist( position, mVect );
       
       // CHeck if in radius.
       if( d < 50 ) { 
         
         // Subtract vectors to get a vector from origin (0,0)
         PVector bVect = PVector.sub( mVect, position );
         
         float theta;
         theta = atan2( mVect.y - position.y, mVect.x - position.x );
         
         // Inverse d, so that the further from the mouse,
         // the slower the additional velocity away. 
         d = 50 - d;
         velocity.x -= ( d * cos( theta) ) *  0.02;
         velocity.y -= ( d * sin( theta) ) *  0.02;
       }
          
    } 
  }
  
  // Simply multiply by a small number.
  void applyFriction() {
     velocity.mult( FRICTION_GAIN );
     //velocity.y += 0.9;
  }
  
  void checkCollisionWithOthersKDTree() {
     int i = kd_tree.getNNIndex( new Point( this.position.x, this.position.y, this.id ) ); 
     if( i < 0 ) return;
     
     checkCollision( particles[i] );
  }
  
 

  // Alternative collision with screen, wrap around edges
  // instead.
  void wrapBoundaryCollision() {
     if( position.x > width ) position.x -= width;
     if( position.x < 0 ) position.x += width;
     if( position.y < 0 ) position.y += height;
     if( position.y > height ) position.y -= height; 
  }

  // Inverse the velocity depending on the screen
  // edge collision.
  void checkBoundaryCollision() {
    if (position.x > width-r) {
      position.x = width-r;
      velocity.x *= -1;
    } 
    else if (position.x < r) {
      position.x = r;
      velocity.x *= -1;
    } 
    else if (position.y > height-r) {
      position.y = height-r;
      velocity.y *= -1;
    } 
    else if (position.y < r) {
      position.y = r;
      velocity.y *= -1;
    }
  }

  boolean checkCollision(Particle_c other) {
    boolean collision;
    
    
    // get distances between the balls components
    PVector bVect = PVector.sub(other.position, position);

    // calculate magnitude of the vector separating the balls
    float bVectMag = bVect.mag();

    collision = false;    

    // If there is contact
    if (bVectMag < r + other.r) {
      
      collision = true;
      
      // heading() is not working on openprocessing.org
      // get angle of bVect
      //float theta  = bVect.heading();
      float theta;
      theta = atan2( other.position.y - position.y, other.position.x - position.x );
      
      
      // precalculate trig values
      float sine = sin(theta);
      float cosine = cos(theta);

      /* bTemp will hold rotated ball positions. You 
       just need to worry about bTemp[1] position*/
      PVector[] bTemp = {
        new PVector(), new PVector()
        };

        /* this ball's position is relative to the other
         so you can use the vector between them (bVect) as the 
         reference point in the rotation expressions.
         bTemp[0].position.x and bTemp[0].position.y will initialize
         automatically to 0.0, which is what you want
         since b[1] will rotate around b[0] */
        bTemp[1].x  = cosine * bVect.x + sine * bVect.y;
      bTemp[1].y  = cosine * bVect.y - sine * bVect.x;

      // rotate Temporary velocities
      PVector[] vTemp = {
        new PVector(), new PVector()
        };

      vTemp[0].x  = cosine * velocity.x + sine * velocity.y;
      vTemp[0].y  = cosine * velocity.y - sine * velocity.x;
      vTemp[1].x  = cosine * other.velocity.x + sine * other.velocity.y;
      vTemp[1].y  = cosine * other.velocity.y - sine * other.velocity.x;

      /* Now that velocities are rotated, you can use 1D
       conservation of momentum equations to calculate 
       the final velocity along the x-axis. */
      PVector[] vFinal = {  
        new PVector(), new PVector()
        };

      // final rotated velocity for b[0]
      vFinal[0].x = ((m - other.m) * vTemp[0].x + 2 * other.m * vTemp[1].x) / (m + other.m);
      vFinal[0].y = vTemp[0].y;

      // final rotated velocity for b[0]
      vFinal[1].x = ((other.m - m) * vTemp[1].x + 2 * m * vTemp[0].x) / (m + other.m);
      vFinal[1].y = vTemp[1].y;

      // hack to avoid clumping
      bTemp[0].x += vFinal[0].x;
      bTemp[1].x += vFinal[1].x;

      /* Rotate ball positions and velocities back
       Reverse signs in trig expressions to rotate 
       in the opposite direction */
      // rotate balls
      PVector[] bFinal = { 
        new PVector(), new PVector()
        };

      bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
      bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
      bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
      bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;

      // update balls to screen position
      other.position.x = position.x + bFinal[1].x;
      other.position.y = position.y + bFinal[1].y;

      position.add(bFinal[0]);
      
      // add the overlap distance to stop clumping.
      float overlap = (r + other.r) - bVectMag;
      position.x -= cos( theta ) * overlap;
      position.y -= sin( theta ) * overlap;  

      // update velocities
      velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y;
      velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x;
      other.velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y;
      other.velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x;
      
    } 
    
    return collision;
  }


  void display() {
    noStroke();
    color c = lerpColor( c1, c2, map( velocity.mag(), 0, 4, 0,1) );
    fill(c);
    ellipse(position.x, position.y, r*2, r*2);
  }
}


public  class Quicksort {
  private int dim = 0;
  private Point[] points;
  private Point points_t_;

  public void sort(Point[] points, int dim) {
    if (points == null || points.length == 0) return;
    this.points = points;
    this.dim = dim;
    quicksort(0, points.length - 1);
  }

  private void quicksort(int low, int high) {
    int i = low, j = high;
    Point pivot = points[low + ((high-low)>>1)];

    while (i <= j) {
      if ( dim == 0 ) {
        while (points[i].x < pivot.x) i++;
        while (points[j].x > pivot.x) j--;
      } else {
        while (points[i].y < pivot.y) i++;
        while (points[j].y > pivot.y) j--;
      }
      if (i <= j)  exchange(i++, j--);
    }
    if (low <  j) quicksort(low, j);
    if (i < high) quicksort(i, high);
  }

  private void exchange(int i, int j) {
    points_t_ = points[i];
    points[i] = points[j];
    points[j] = points_t_;
  }
}
}