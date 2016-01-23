#include <AccelStepper.h>



// Stepper driver pins
#define STEP_PIN 4
#define DIRECTION_PIN 5


#define MICROSTEPS 8
#define STEPS_PER_REV 200
#define REVS_PER_SECOND 2

#define STEPS_PER_SEC (MICROSTEPS*STEPS_PER_REV*REVS_PER_SECOND)
boolean enableStepper = true; // just to be able to test withut the stepper running

// Define a stepper and the pins it will use
AccelStepper stepper(AccelStepper::DRIVER, STEP_PIN, DIRECTION_PIN);

void setup()
{  

  
  if( enableStepper )
  {
    /*
    stepper.setMaxSpeed(MICROSTEPS*STEPS_PER_REV*REVS_PER_SECOND);
    stepper.setAcceleration(6400);
    stepper.moveTo(MICROSTEPS*STEPS_PER_REV*10);
    */
    
    stepper.setMaxSpeed(STEPS_PER_SEC);
    stepper.setSpeed(100);
  }
  

 
}

long lastSpeedup = 0;

void loop()
{
 

  loopStepper();
}

void loopStepper()
{
  long now = millis();
  


  if( enableStepper )
  {

    if( stepper.speed() < STEPS_PER_SEC && now - lastSpeedup > 1)
    {
      lastSpeedup = now;
       stepper.setSpeed(stepper.speed()+1);
    }   
    stepper.runSpeed();
  }
}
