
// We'll have one Effect active at a time. The Effect generates all our visualisation from its draw method.
abstract class Effect 
{
  void start(){}
  abstract void draw(ArrayList<Reading> readings, ArrayList<Reading> feet, ArrayList<Person> people);
  void notifyNewFoot( Reading foot ){}
}