
/* foot_fall_field_lidar
 *  
 *  This runs on an Arduino Nano wired to a LidarLite lidar sensor.
 *  There's a rotating mirror that scans the beam through 360 degrees,
 *  and a hall effect sensor detects a magnet on the rotating assembly to give us an index pulse.
 *  
 *  For performance reasons, the rotation is handled by a stepper run by a second Arduino Nano, running the
 *  foot_fall_field_stepper sketch.
 *  
 *  Range and angle data of the objects detected by the lidar is sent over serial to 
 *  a Processing sketch, FootFallField, running on a Pi.
 */
 
#include <Wire.h>
#include <LIDARLite.h>

LIDARLite myLidarLite;
int lidarReadCount = 0;

// Copy these two from foot_fall_field_stepper
#define MICROSTEPS 8
#define STEPS_PER_REV 200



boolean lastIndexSense = false;
unsigned long indexMicros = 0;
unsigned long periodMicros = 0;
unsigned long ticksPerRev = MICROSTEPS * STEPS_PER_REV * 8;


#define INDEX_SENSOR_PIN 3 // the hall effect sensor
#define LED_PIN 13 // the Nano's built-in LED

void setup()
{  
  Serial.begin(115200);

  //  First we want to set the aquisition count to 1/3 the default (works great for stronger singles)
  //  can be a little noisier (this is the "1"). Then we set the "true" to enable 400kHz i2c
  //  communication speed.

  myLidarLite.begin(1,true);


  
  pinMode(INDEX_SENSOR_PIN, INPUT);
  pinMode(LED_PIN, OUTPUT);

  digitalWrite(LED_PIN, true);
  delay(1000);
  digitalWrite(LED_PIN, false);
  
 
 
}


void loop()
{
  loopLidar();
  loopIndex();
 
}

void loopLidar()
{
   int range = readLidar();
   if( periodMicros != 0 &&       // had our first rev 
        periodMicros < 100000000 )  // not wrapped round
        {
           unsigned long now = micros(); 
           unsigned long tick = (now - indexMicros) * ticksPerRev / periodMicros;
           printWord(tick);
           printWord(range);
           printNull();
           //Serial.print( tick );
           //Serial.print( " : " );
           //Serial.println( range );
        }
}

void printWord( unsigned long w )
{
  // two bytes, 7 bits per byte, with the top bit set
  byte b1;

  byte b2;
  
  b1 = w & 0x7f;
  b2 = (w >> 7) & 0x7f;

  b1 |= 0x80;
  b2 |= 0x80;
  Serial.write( b1);
  Serial.write( b2);  
}

void printNull()
{
  Serial.write( 0);
}

int readLidar()
{
   int range;
  if( lidarReadCount == 0 )
    //  Next we need to take 1 reading with preamp stabilization and reference pulse (these default to true)
    range = myLidarLite.distance();
  else
    range = myLidarLite.distance(false,false);    // Next lets take 99 reading without preamp stabilization and reference pulse (these read about 0.5-0.75ms faster than with)

   lidarReadCount ++;
   if( lidarReadCount > 100 )
     lidarReadCount = 0;

     return range;
}


void loopIndex()
{
   boolean indexSense = !digitalRead(INDEX_SENSOR_PIN);
   digitalWrite(LED_PIN, indexSense);

   if( indexSense && ! lastIndexSense )
   {
      // start of pulse
      unsigned long now = micros(); 
      if( indexMicros != 0 )
        periodMicros = now - indexMicros;
        
      indexMicros = now;

      // mark start of rotation with two nulls
      printNull();
      printNull();
    
   }
   lastIndexSense = indexSense;



}
