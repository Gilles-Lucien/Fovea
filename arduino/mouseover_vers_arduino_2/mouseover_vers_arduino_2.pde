import processing.serial.*; 
 // message test pour tuto git
 //rectangle 1
 float boxX;
 float boxY;
 float boxX2;
 float boxY2;
 //rectangle 2
 float box2X;
 float box2Y;
 float box2X2;
 float box2Y2;
 
 boolean mouseOverBox = false;
 boolean mouseOverBox2 = false;
 
 Serial port; 
 
 void setup()  {
 size(500, 200);
//rectangle 1
 boxX = 0;
 boxY = 0;
 boxX2 = width/2;
 boxY2 = height;
//rectangle 2 
 box2X = width/2;
 box2Y = 0;
 box2X2 = width;
 box2Y2 = height;
 rectMode(CORNER); 
 
 // List all the available serial ports in the output pane. 
 // You will need to choose the port that the Arduino board is 
 // connected to from this list. The first port in the list is 
 // port #0 and the third port in the list is port #2. 
 println(Serial.list()); 
 
 // Open the port that the Arduino board is connected to (in this case #0) 
 // Make sure to open the port at the same speed Arduino is using (9600bps) 
 port = new Serial(this, Serial.list()[0], 9600); 
 
 }
 
 void draw() 
 { 
 background(0);
 
 // Test if the cursor is over the box1
 if (mouseX > boxX && mouseX < boxX2 && 
 mouseY > boxY && mouseY < boxY2) {
 mouseOverBox = true;  
 // draw a line around the box and change its color:
 stroke(10); 
 fill(100);
 // send an 'H' to indicate mouse is over square:
 port.write('H');       
 } 
 else {
 // return the box to it's inactive state:
 stroke(255);
 fill(153);
 // send an 'L' to turn the LED off: 
 port.write('L');      
 mouseOverBox = false;
 }
 
 // Draw the box
 rect(boxX, boxY, boxX2, boxY2);
 
  // Test if the cursor is over the box2
 if (mouseX > box2X && mouseX < box2X2 && 
 mouseY > box2Y && mouseY < box2Y2) {
 mouseOverBox = true;  
 // draw a line around the box and change its color:
 stroke(10); 
 fill(100);
 // send an 'A' to indicate mouse is over square:
 port.write('A');       
 } 
 else {
 // return the box to it's inactive state:
 stroke(255);
 fill(153);
 // send an 'I' to turn the LED off: 
 port.write('I');      
 mouseOverBox = false;
 }
 //Draw the box 2
 rect(box2X, box2Y, box2X2, box2Y2);
 }
