
// Infers the people from the feet
// A series of steps near each other will be treated as a single person

class PersonManager
{
  public ArrayList<Person> people = new ArrayList<Person>();
  
  void updateForFoot( Reading foot )
  {
    float bestRange = 0;
    Person bestPerson = null;
    
    synchronized( people )
    {
      // Find the person whose forecast position is closest to this foot
      for( Person person : people )
      {
        float d =  person.forecastDistanceFrom( foot );
        if( d < Person.compatibleDistance )
        {
          if( d < bestRange || bestPerson == null )
          {
            bestRange = d;
            bestPerson = person;
          }
        }
      }
    
      if( bestPerson != null )
      {
        bestPerson.newFoot( foot );
        return;
      }

      // If we didn't find one, make a new person
      people.add( new Person(foot));
    } 
  }
  
  
  void cleanBeforeRotation( int rotationCounter )
  {
     synchronized( people )
    {
      for( int i = 0; i < people.size(); )
      {
        Person person = people.get(i);
        if( person.rotationCounter < rotationCounter - 2 ) // If we've not seen them for a few revs
        {
            people.remove(i); // assume they have left
        }
        else
        {
          i++;
        }
      }
    }
  }
}