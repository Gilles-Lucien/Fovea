/* SOURCES :
 - Super Fast Blur v1.1 by Mario Klingemann <http://incubator.quasimondo.com>
 - BlobDetection library by V3ga http://www.v3ga.net/processing/BlobDetection/index-page-documentation.html
 - FPSTracker by BonjourLab
 - Debug Blob Detection by BonjourLab
 */


import blobDetection.*;

Kinect kinect;

PImage depth;
float level;
BlobDetection[] theBlobDetection; //Objet BlobDetection qui contiendra tous les blob dans une liste
PImage img; //Texture copie de l'input pour analyse
ArrayList<Blob> blobList;
ArrayList<Float> index;

//Debug
FPSTracking fpsTracker; //Tracker de frameRate permettant de monitorer des chutes de performance

 float boxX;
 float boxY;
 float boxX2;
 float boxY2;
 //rectangle 2
 float box2X;
 float box2Y;
 float box2X2;
 float box2Y2;
 import processing.serial.*; 

  Serial port; 

 
void setup()
{

  // input 
  depth = loadImage("depth_2.jpg");

  float w = 640*2; //larger du fps tracker
  float h = 100; //hauteur du fps tracker
  fpsTracker = new FPSTracking(floor(w), 60, w, h);

  size(int(w), 480+int(h), P3D);

  PApplet context = this;
  kinect = new Kinect(context);

  // BlobDetection
  level = 3;
  float scale = 0.25; //ratio de reduction de l'image source
  img = new PImage(floor(640 * scale), floor(480*scale)); //Copie de l'image source qui sera envooyé à la detection. Celle-ci est volontairement plus petite pour gagner en performance 
  theBlobDetection = new BlobDetection[int(level)];
  blobList  = new ArrayList<Blob>();
  index = new ArrayList<Float>();
  
  
   // List all the available serial ports in the output pane. 
 // You will need to choose the port that the Arduino board is 
 // connected to from this list. The first port in the list is 
 // port #0 and the third port in the list is port #2. 
 println(Serial.list()); 
 
 // Open the port that the Arduino board is connected to (in this case #0) 
 // Make sure to open the port at the same speed Arduino is using (9600bps) 
 port = new Serial(this, Serial.list()[0], 9600); 

boxX = 0;
 boxY = 0;
 boxX2 = img.width/2;
 boxY2 = img.height;
//rectangle 2 
 box2X = img.width/2;
 box2Y = 0;
 box2X2 = img.width;
 box2Y2 = img.height;
}

void draw()
{
  background(0);
  //depth = loadImage("depth.jpg");

  //Detect
  fpsTracker.run(frameRate);
  image(fpsTracker.getImageTracker(), 0, height - fpsTracker.h);
  kinect.computeKinectOffscreenTexture();
  //image(kinect.getOriginalKinectOffscreenTexture(), 0, 0, depth.width, depth.height); //affiche l'image source
  img.copy(kinect.getOriginalKinectOffscreenTexture(), 0, 0, kinect.getOriginalKinectOffscreenTexture().width, kinect.getOriginalKinectOffscreenTexture().height, 0, 0, img.width, img.height); //copy l'image source dans un texture   
  fastblur(img, 3); //Floute la texture
  image(img, depth.width, 0, depth.width/2, depth.height/2); //affiche la texture

  computeBlobDetection();

  fill(255);
  text("Nombre de Blobs : " + getNbBlobs(), depth.width +10, depth.height/2 + 20);
 
 boolean left = false;
 boolean right = false;
  
  for (int n = 0; n < getNbBlobs(); n++)
  {
    Blob b = blobList.get(n);

    if (b != null) {
      float mouseX = (b.xMin + ((b.xMax - b.xMin)/2)) * img.width;
      float mouseY = (b.yMin + ((b.yMax - b.yMin)/2)) * img.height;
      println("MOUSE: " + mouseX + " - " + mouseY);
      println("IMG: " + img.width + " - " + img.height);
      if (mouseX > boxX && mouseX < boxX2 && 
          mouseY > boxY && mouseY < boxY2) {
        left = true;
      } 
   
      // Test if the cursor is over the box2
      if (mouseX > box2X && mouseX < box2X2 && 
          mouseY > box2Y && mouseY < box2Y2) {
         right = true;           
      } 
    }
    
    if (left && right) {
     break ; 
    }
  }
  println("LED " + left + " - " + right);
  if (left)
     port.write('H');
  else
     port.write('L');      

  if (right)
    port.write('A');
  else
    port.write('I');     

  
    drawBlobsAndEdges(depth); //dessine les blob

}

