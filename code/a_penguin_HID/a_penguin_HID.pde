// Penguin Interface code for sending keystrokes from arduino to computer via HID bluetooth module
// project page >> http://www.plusea.at/?page_id=2700

#include <stdarg.h>
#include "pitches.h"

////////////////////////
// EDITABLE VARIABLES //
////////////////////////
boolean consoleMode = false;
boolean debugAccel = consoleMode && false;

int keyDelay = 3000;  // number of milli-seconds between key presses when key pressed
int lightDelay = 1400;  // number of milli-seconds between LED light colours

int squeezeThreshold = 900; // sensor value needs to go bellow this value to trigger

int rightWingThresholdMIN = 200; // sensor value needs to go bellow this value to trigger
int rightWingThresholdMAX = 400; // sensor value needs to stay above this value not to trigger

int forwardTileAccelThresholdMAX = 640; // sensor needs to go below this value to be considered tilting forward
int backTiltAccelThresholdMIN = 830;  // sensor needs to go above this value to be considered tilting backward

int leftWingThresholdMIN = 200; // sensor value needs to go bellow this value to trigger
int leftWingThresholdMAX = 400; // sensor value needs to stay above this value not to trigger

//////////
// PINS //
//////////
// INPUTS
int rBendPin = A0;  // analog
int lBendPin = A1;  // analog
int squeezePin = A2;  // analog
int xPin = A3;  // analog
int yPin = A4;  // analog
int zPin = A5;  // analog
int tilt1Pin = 7;  // digital
int tilt2Pin = 8;  // digital
int strokePin;  // digital
int beakPin;  // digital
int inputs[] = {
  A0,A1,A2,A3,A4,A5,7,8};  //8
int pullups[] = {
  14,15,16,17,18,19,7,8};  //8

// OUTPUTS
int rLEDPin = 6; // PWM
int gLEDPin = 5; // PWM
int bLEDPin = 3; // PWM
int speakerPin = 4;
int vibePin = 9; // PWM
int outputs[] = {
  5,6,3,4,9};  //5

//////////
// WIFI //
//////////
int WiFlyPin1 = 10;
int WiFlyPin2 = 11;
int WiFlyPin3 = 12;
int WiFlyPin4 = 13;

////////////
// INPUTS //
////////////
// INCOMING VALUES
int rBend, lBend, squeeze, tilt1, tilt2, x, y, z;
int rightBendAmount, leftBendAmount, squeezeAmount, tiltDirection;
byte inByte;

///////////
// SOUND //
///////////
// notes in the melody:
int melody[] = {
  NOTE_C4, NOTE_G3,NOTE_G3, NOTE_A3, NOTE_G3,0, NOTE_B3, NOTE_C4};
// note durations: 4 = quarter note, 8 = eighth note, etc.:
int noteDurations[] = {
  4, 8, 8, 4,4,4,4,4 };

///////////
// LIGHT //
///////////
int rgb;  //for keeping track of LED light colour
int light;  //for keeping track ot LED colour change timing

//////////
// KEYS //
//////////
byte right = consoleMode ? 'r' : 0x07;
byte left = consoleMode ? 'l' : 0x0B;
byte up = consoleMode ? 'u' : 0x0E;
byte down = consoleMode ? 'd' : 0x0C;
byte enter = consoleMode ? 'N' : 0x0D;
byte one = '1';
int u,d,r,l,e,o;  //for keeping track of keyDelay time



void printfmt(char *fmt, ... );


///////////
// SETUP //
///////////
void setup() {
  for(int i = 0; i < 5; i++){
    pinMode(outputs[i],OUTPUT);
  }

  for(int i = 0; i < 8; i++){
    pinMode(inputs[i],INPUT);
  }

  for(int i = 0; i < 8; i++){
    digitalWrite(pullups[i],HIGH);
  }

  Serial.begin(115200);
  noTone(speakerPin);
}



void printfmt(char *fmt, ... );



//////////
// LOOP //
//////////
void loop() {

  readInput();

  // tilt back --> down (using only tilt)
  //repeatKey(down, &d, tilt1 == 1 && tilt2 == 1);
  
  // tilt forward --> down (using acceleration)
  repeatKey(down, &d, (tilt1 == 0 || tilt2 == 0) && y < forwardTileAccelThresholdMAX);
  
  // tilt back --> up (using acceleration)
  repeatKey(up, &u, (tilt1 == 0 || tilt2 == 0) && y > backTiltAccelThresholdMIN);
  
  // squeeze or bend both wings --> up
  //repeatKey(up, &u, rBend < rightWingThresholdMIN && lBend < leftWingThresholdMIN);


  // tilt right --> right
  repeatKey(right, &r, tilt1 == 1 && tilt2 == 0 && y > forwardTileAccelThresholdMAX && y < backTiltAccelThresholdMIN);
  
  // tilt left --> left
  repeatKey(left, &l, tilt1 == 0 && tilt2 == 1 && y > forwardTileAccelThresholdMAX && y < backTiltAccelThresholdMIN);



  repeatKey(enter, &e, lBend < leftWingThresholdMIN && rBend > rightWingThresholdMAX);
  repeatKey(one, &o, rBend < rightWingThresholdMIN && lBend > leftWingThresholdMAX);


  /*
  // squeeze or bend left wing only --> play melody
  if(lBend < leftWingThresholdMIN && rBend > rightWingThresholdMAX) {
    play(1);
  }
  else noTone(speakerPin);
  */


  //vibeAndKey(enter, &e, squeeze < squeezeThreshold);

  //cycleLedColors(rBend < rightWingThresholdMIN && lBend > leftWingThresholdMAX);
}


void readInput() {
  // read input pins and assign incoming values to variables
  rBend = analogRead(rBendPin);
  lBend = analogRead(lBendPin);
  squeeze = analogRead(squeezePin);
  x = analogRead(xPin);
  y = analogRead(yPin);
  z = analogRead(zPin);
  tilt1 = digitalRead(tilt1Pin);
  tilt2 = digitalRead(tilt2Pin);

  if(debugAccel) {
    printfmt("x,y,z=(%i, %i, %i)\n", x, y, z);
  } 
}

void vibeAndKey(byte key, int* state, boolean active) {

  // Squeeze --> press enter key and vibrate
  if(active){
    analogWrite(vibePin, 255);
  }
  if(active && *state == 1) {
    *state = 0;  //key is only pressed once
    Serial.write(key);
    delay(25); // must delay 25 milli-seconds after each keypress!
  }
  
  if(active) {
    *state = 1;
    analogWrite(vibePin, 0);
  }
}


void repeatKey(byte key, int* state, boolean active) {
  if(active) {
    if(*state == 0 || *state % keyDelay == 0) {
      Serial.write(key);
      delay(25); // must delay 25 milli-seconds after each keypress!
    }
    (*state)++;
  } else {
    *state = 0; 
  }
}


void cycleLedColors(boolean active) {
  static int rgb = 0, light = 0;
  
  // squeeze or bend right wing only --> toggle through LED colours
  if(active) {
    if(light == 0 || light % lightDelay == 0) {
      rgb++;
    }
    light++;
  }
  else {
    light = 0;
    rgb = 0;
    analogWrite(rLEDPin, 0);
    analogWrite(gLEDPin, 0);
    analogWrite(bLEDPin, 0);
  }

  // LED red
  if(rgb == 1) {
    analogWrite(rLEDPin, 255);
    analogWrite(gLEDPin, 0);
    analogWrite(bLEDPin, 0);
  }

  // LED red and green
  if(rgb == 2) {
    analogWrite(rLEDPin, 150);
    analogWrite(gLEDPin, 255);
    analogWrite(bLEDPin, 0);
  }

  // LED green
  if(rgb == 3) {
    analogWrite(rLEDPin, 0);
    analogWrite(gLEDPin, 255);
    analogWrite(bLEDPin, 0);
  }

  // LED green and blue
  if(rgb == 4) {
    analogWrite(rLEDPin, 0);
    analogWrite(gLEDPin, 255);
    analogWrite(bLEDPin, 255);
  }

  // LED blue
  if(rgb == 5) {
    analogWrite(rLEDPin, 0);
    analogWrite(gLEDPin, 0);
    analogWrite(bLEDPin, 255);
  }

  // LED blue and red
  if(rgb == 6) {
    analogWrite(rLEDPin, 150);
    analogWrite(gLEDPin, 0);
    analogWrite(bLEDPin, 255);
  }

  // LED white
  if(rgb == 7) {
    analogWrite(rLEDPin, 255);
    analogWrite(gLEDPin, 255);
    analogWrite(bLEDPin, 255);
  }

  if(rgb > 7) rgb = 0;
}



///////////
// SOUND //
///////////
void play(int vol) {
  int volume = vol;
  for (int thisNote = 0; thisNote < 8; thisNote++) {

    // to calculate the note duration, take one second 
    // divided by the note type.
    //e.g. quarter note = 1000 / 4, eighth note = 1000/8, etc.
    int noteDuration = 1000/noteDurations[thisNote];
    tone(speakerPin, volume*melody[thisNote],noteDuration);

    // to distinguish the notes, set a minimum time between them.
    // the note's duration + 30% seems to work well:
    int pauseBetweenNotes = noteDuration * 1.30;
    delay(pauseBetweenNotes);
    // stop the tone playing:
    inByte = 'n';
  }
}


void printfmt(char *fmt, ... ){
        char tmp[128]; // resulting string limited to 128 chars
        va_list args;
        va_start (args, fmt );
        vsnprintf(tmp, 128, fmt, args);
        va_end (args);
        Serial.print(tmp);
}




