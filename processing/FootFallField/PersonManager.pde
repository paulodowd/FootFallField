class PersonManager
{
  public ArrayList<Person> people = new ArrayList<Person>();
  
  void updateForFoot( Reading foot )
  {
    synchronized( people )
    {
    for( Person person : people )
      if( person.consistentWith( foot )) //TODO - should pick the best person, not the first plausible one
      {
        person.newFoot( foot );
        return;
      }
      
    if( people.size() == 0 )
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