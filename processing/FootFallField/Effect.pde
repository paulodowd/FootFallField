
// Base class for all our effects
// We'll have one Effect active at a time. The Effect generates all our visualisation from its draw method.

abstract class Effect 
{
  String imageName() { return null; }
  
  void start(){}
  
  abstract void draw(                               // Draw the effect based on: 
                      ArrayList<Reading> readings,  // All the lidar readings
                      ArrayList<Reading> feet,      // The feet, abstracted from the lidar readings
                      ArrayList<Person> people);    // The people, abstracted from the feet
                      
  void notifyNewFoot( Reading foot ){}              // Called when a new foot is added to feet 
                                                    // TODO - currently called on each scan, even if foot hasn't moved - 
                                                    // could call only when a fresh foot is discovered ? Or pass a flag to indicate newness ?
}