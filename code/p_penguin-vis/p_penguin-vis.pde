/*
Penguin visualization code >> http://www.plusea.at/?p=2378
 */

import processing.serial.*;

void setup(){
size(600, 600); 

  //////////// SERIAL PORT ///////////
  println(Serial.list());  // prints a list of the serial ports

  //////// LEFT ////////
  leftPort = new Serial(this, "/dev/tty.RN42-059C-SPP", 115200);  ///// BLUETOOTH /////
  //leftPort = new Serial(this, "/dev/tty.usbserial-A600f6Tn", 9600);  ///// FTDI /////
  leftPort.clear();
  leftPort.bufferUntil('\n');  // don't generate a serialEvent() until you get a newline (\n) byte

background(115); 
stroke(255);
noFill();
smooth(); 

}

void draw(){
fill(0);
ellipse(width/2, height/4-50, 100,100);
ellipse(width/2, height/2+50, 200, 400);
ellipse(width/2+120, height/2-50, 50,50);
ellipse(width/2-120, height/2-50, 50,50);



fill(255);
ellipse(width/2, height/2+50, 150, 300);




fill(10,134,255);
ellipse(width/2+20, height/4-50, 30,30);
fill(255,243,10);
ellipse(width/2-20, height/4-50, 30,30);



} 
