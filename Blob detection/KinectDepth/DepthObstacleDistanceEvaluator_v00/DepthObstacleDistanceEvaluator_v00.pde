/* SOURCES :
- Super Fast Blur v1.1 by Mario Klingemann <http://incubator.quasimondo.com>
- BlobDetection library by V3ga http://www.v3ga.net/processing/BlobDetection/index-page-documentation.html
- FPSTracker by BonjourLab
- Debug Blob Detection by BonjourLab
*/

import processing.video.*;
import blobDetection.*;

Capture cam; //input camera
BlobDetection theBlobDetection; //Objet BlobDetection qui contiendra tout les blob dans une liste
PImage img; //Texture copie de l'input pour analyse
boolean newFrame=false; //Boolean servant à indiquer si l'input à une nouvelle image à envoyer à l'analyse

//Debug
FPSTracking fpsTracker; //Tracker de frameRate permettant de monitorer des chutes de performance

void setup()
{
  float w = 640*2; //larger du fps tracker
  float h = 100; //hauteur du fps tracker
  fpsTracker = new FPSTracking(floor(w), 60,  w, h);
  
  size(int(w), 480+int(h), P3D);
  
  // input video
  String[] cameras = Capture.list();
  cam = new Capture(this, cameras[0]);
  cam.start();

  // BlobDetection
  float scale = 0.25; //ratio de reduction de l'image source
  img = new PImage(floor(640 * scale), floor(480*scale)); //Copie de l'image source qui sera envooyé à la detection. Celle-ci est volontairement plus petite pour gagner en performance 
  theBlobDetection = new BlobDetection(img.width, img.height);//Objet Blob detection analysant l'image
  theBlobDetection.setPosDiscrimination(true);//défini si on cherche les zone lumineuse (true) ou sombre (false);
  theBlobDetection.setThreshold(0.5f); //Defini le seuil de luminosité au dessus duquel le blob est detecté
}

void draw()
{
  //Detect
  fpsTracker.run(frameRate);
  image(fpsTracker.getImageTracker(), 0, height - fpsTracker.h);
  
  //Analyse et dessin du blob
  if (newFrame)
  {
    newFrame=false;
    
    image(cam, 0, 0, cam.width, cam.height); //affiche l'image source
    img.copy(cam, 0, 0, cam.width, cam.height, 0, 0, img.width, img.height); //copy l'image source dans un texture
    fastblur(img, 2); //Floute la texture
    image(img, cam.width, 0, cam.width, cam.height); //affiche la texture
    
    theBlobDetection.computeBlobs(img.pixels); //analyse la texture pour trouver les blob
    drawBlobsAndEdges(true, true, true, true, cam); //dessine les blob
  } 
  
}


//Thread de capture video. Recupere la nouvelle image renvoyé par la webcam
void captureEvent(Capture cam)
{
  cam.read();
  newFrame = true;
}
