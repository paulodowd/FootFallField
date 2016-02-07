
// We'll have one Effect active at a time. The Effect generates all our visualisaiton.
interface Effect 
{
  void start();
  void draw(ArrayList<Reading> readings, ArrayList<Reading> feet, ArrayList<Person> people);
  void notifyNewFoot( Reading foot );
}