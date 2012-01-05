int rPin = 3; // red
int gPin = 5;  // blue
int bPin = 6;  // green
int readPin = A2;  // squeeze sensor


void setup()  { 
  digitalWrite(16, HIGH);  // pullup resistor  
  pinMode(2,OUTPUT);  // vibration motors
  Serial.begin(9600);  // USB
  //Serial.begin(115200);  //BT
} 



void loop()  { 
  colours();  // test different colours
  //fade();  // test fading
  //digitalWrite(2, HIGH);  // test vibration motors
  //void sensorTest(); // read and print incoming values from sensors
}



void colours(){
  //pink
  analogWrite(3, 75);
  analogWrite(6, 0);
  analogWrite(5, 255);
  delay(1000);

  //orange
  analogWrite(3, 150);
  analogWrite(6, 200);
  analogWrite(5, 0);
  delay(1000);

  //light blue
  analogWrite(3, 0);
  analogWrite(6, 150);
  analogWrite(5, 100);
  delay(1000);

  // white
  analogWrite(3, 50);
  analogWrite(6, 255);
  analogWrite(5, 255);
  delay(1000);

  //yellow
  analogWrite(3, 50);
  analogWrite(6, 255);
  analogWrite(5, 0);
  delay(1000);

}

void fade(){
  for(int fadeValue = 0 ; fadeValue <= 255; fadeValue +=5) { 
    analogWrite(rPin, fadeValue);
    analogWrite(gPin, fadeValue);    
    analogWrite(bPin, fadeValue);
    delay(30);                            
  } 

  for(int fadeValue = 255 ; fadeValue >= 0; fadeValue -=5) { 
    analogWrite(rPin, fadeValue);
    analogWrite(gPin, fadeValue);    
    analogWrite(bPin, fadeValue);
    delay(30);                            
  } 
}



void sensorTest(){
  Serial.println(analogRead(readPin));  // read squeeze sensor value\
  Serial.print(",");
  Serial.println(digitalRead(7));  // read tilt value 1
  Serial.print(",");
  Serial.println(digitalRead(8));  // read tilt value 2
  Serial.println("");  // line break
  delay(100);
}


