/* SOURCES :
 - Super Fast Blur v1.1 by Mario Klingemann <http://incubator.quasimondo.com>
 - BlobDetection library by V3ga http://www.v3ga.net/processing/BlobDetection/index-page-documentation.html
 - FPSTracker by BonjourLab
 - Debug Blob Detection by BonjourLab
 */

import processing.video.*;
import blobDetection.*;


Capture cam; //input camera
PImage depth;
float level;
BlobDetection[] theBlobDetection; //Objet BlobDetection qui contiendra tout les blob dans une liste
PImage img; //Texture copie de l'input pour analyse
ArrayList<Blob> blobList;
ArrayList<Float> index;

//Debug
FPSTracking fpsTracker; //Tracker de frameRate permettant de monitorer des chutes de performance

boolean newFrame;

void setup()
{

  // input 
  depth = loadImage("depth_2.jpg");

  float w = 640*2; //larger du fps tracker
  float h = 100; //hauteur du fps tracker
  fpsTracker = new FPSTracking(floor(w), 60, w, h);

  size(int(w), 480+int(h), P3D);


  String[] cameras = Capture.list();
  cam = new Capture(this, cameras[0]);
  cam.start();

  // BlobDetection
  level = 5;
  float scale = 0.12; //ratio de reduction de l'image source
  img = new PImage(floor(640 * scale), floor(480*scale)); //Copie de l'image source qui sera envooyé à la detection. Celle-ci est volontairement plus petite pour gagner en performance 
  theBlobDetection = new BlobDetection[int(level)];
  blobList  = new ArrayList<Blob>();
  index = new ArrayList<Float>();
}

void draw()
{
  background(0);
  //depth = loadImage("depth.jpg");

  //Detect
  fpsTracker.run(frameRate);
  image(fpsTracker.getImageTracker(), 0, height - fpsTracker.h);

  if (newFrame)
  {
    //newFrame = false;
    //image(cam, 0, 0, depth.width, depth.height); //affiche l'image source
    img.copy(cam, 0, 0, cam.width, cam.height, 0, 0, img.width, img.height); //copy l'image source dans un texture
    fastblur(img, 2); //Floute la texture
    image(img, depth.width, 0, depth.width/2, depth.height/2); //affiche la texture

    computeBlobDetection();
    drawBlobsAndEdges(depth); //dessine les blob

    fill(255);
    text("Nombre de Blobs : " + getNbBlobs(), depth.width +10, depth.height/2 + 20);
  }
}

//Thread de capture video. Recupere la nouvelle image renvoyé par la webcam
void captureEvent(Capture cam)
{
  cam.read();
  newFrame = true;
}

