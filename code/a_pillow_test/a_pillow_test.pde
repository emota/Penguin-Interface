int rPin = 3; // red
int gPin = 6;  // green
int bPin = 5;  // blue
int readPin = A2;  // squeeze sensor
float rValue, gValue, bValue;
float redDifference, blueDifference, greenDifference;
int fadeTime = 30;

void setup()  { 
  digitalWrite(16, HIGH);  // pullup resistor  
  pinMode(2,OUTPUT);  // vibration motors
  Serial.begin(9600);  // USB
  //Serial.begin(115200);  //BT
} 



void loop()  { 
  //rgb();
  controlledFade(150,255,0, 0,255,100);  //orange to turquoise
  controlledFade(0,255,100, 0,50,255);  //turquoise to dark blue
  controlledFade(0,50,255, 0,255,255);  // dark blue to light blue
  controlledFade(0,255,255, 20,50,250);  //light blue to purple
  controlledFade(20,50,250, 50,255,255);  //purple to white
  controlledFade(50,255,255, 50,250,0);  //white to yellow
  controlledFade(50,250,0, 100,0,250);  //yellow to pink
  controlledFade(100,0,250, 150,255,0);  //pink to orange
  //colours();  // test different colours
  //fade();  // test fading
  //digitalWrite(2, HIGH);  // test vibration motors
  //void sensorTest(); // read and print incoming values from sensors
}




void controlledFade(int r1,int g1,int b1, int r2,int g2,int b2){
  int red1 = r1;
  int green1 = g1;
  int blue1 = b1;
  int red2 = r2;
  int green2 = g2;
  int blue2 = b2;

  redDifference = 255.0 / (red1 - red2);
  greenDifference = 255.0 / (green1 - green2);
  blueDifference = 255.0 / (blue1 - blue2);

  Serial.print("differences");  // for testing purposes print difference values
  Serial.print(",");
  Serial.print(redDifference);
  Serial.print(",");
  Serial.print(greenDifference);
  Serial.print(",");
  Serial.print(blueDifference);
  Serial.println("");

  for(int fadeValue = 0 ; fadeValue <= 255; fadeValue++) { 
    rValue = red1 - fadeValue/redDifference;
    gValue = green1 - fadeValue/greenDifference;
    bValue = blue1 - fadeValue/blueDifference;
    
    analogWrite(rPin, rValue);
    analogWrite(gPin, gValue);    
    analogWrite(bPin, bValue);
    delay(fadeTime);  
  } 
  
  Serial.print("colour");  // for testing purposes print colour values
  Serial.print(",");
  Serial.print(rValue);
  Serial.print(",");
  Serial.print(gValue);
  Serial.print(",");
  Serial.print(bValue);
  Serial.println("");
}



void colours(){

  //orange
  analogWrite(rPin, 150);
  analogWrite(gPin, 250);
  analogWrite(bPin, 0);
  delay(1000);

  //turquoise
  analogWrite(rPin, 0);
  analogWrite(gPin, 255);
  analogWrite(bPin, 100);
  delay(1000);

  //dark blue
  analogWrite(rPin, 0);
  analogWrite(gPin, 50);
  analogWrite(bPin, 250);
  delay(1000);

  //purple
  analogWrite(rPin, 20);
  analogWrite(gPin, 50);
  analogWrite(bPin, 250);
  delay(1000);

  //light blue
  analogWrite(rPin, 0);
  analogWrite(gPin, 250);
  analogWrite(bPin, 250);
  delay(1000);

  // white
  analogWrite(rPin, 50);
  analogWrite(gPin, 250);
  analogWrite(bPin, 250);
  delay(1000);

  //yellow
  analogWrite(rPin, 50);
  analogWrite(gPin, 250);
  analogWrite(bPin, 0);
  delay(1000);

  //pink
  analogWrite(rPin, 100);
  analogWrite(gPin, 0);
  analogWrite(bPin, 250);
  delay(1000);

}


void rgb(){
  //red
  analogWrite(3, 255);
  analogWrite(6, 0);
  analogWrite(5, 0);
  delay(1000);

  //green
  analogWrite(3, 0);
  analogWrite(6, 255);
  analogWrite(5, 0);
  delay(1000);

  //blue
  analogWrite(3, 0);
  analogWrite(6, 0);
  analogWrite(5, 255);
  delay(1000);
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





