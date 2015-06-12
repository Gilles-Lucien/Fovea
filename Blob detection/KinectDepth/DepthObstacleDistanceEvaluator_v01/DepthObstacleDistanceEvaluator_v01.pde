/* SOURCES :
 - Super Fast Blur v1.1 by Mario Klingemann <http://incubator.quasimondo.com>
 - BlobDetection library by V3ga http://www.v3ga.net/processing/BlobDetection/index-page-documentation.html
 - FPSTracker by BonjourLab
 - Debug Blob Detection by BonjourLab
 */

import blobDetection.*;

PImage depth;
BlobDetection theBlobDetection; //Objet BlobDetection qui contiendra tout les blob dans une liste
PImage img; //Texture copie de l'input pour analyse
float threshold;

//Debug
FPSTracking fpsTracker; //Tracker de frameRate permettant de monitorer des chutes de performance

void setup()
{
  // input 
  depth = loadImage("depth_2.jpg");

  float w = depth.width*2; //larger du fps tracker
  float h = 100; //hauteur du fps tracker
  fpsTracker = new FPSTracking(floor(w), 60, w, h);

  size(int(w), depth.height+int(h), P3D);


  // BlobDetection
  float threshold = 0.85;
  float scale = 0.25; //ratio de reduction de l'image source
  img = new PImage(floor(640 * scale), floor(480*scale)); //Copie de l'image source qui sera envooyé à la detection. Celle-ci est volontairement plus petite pour gagner en performance 
  theBlobDetection = new BlobDetection(img.width, img.height);//Objet Blob detection analysant l'image
  theBlobDetection.setPosDiscrimination(true);//défini si on cherche les zone lumineuse (true) ou sombre (false);
  theBlobDetection.setThreshold(threshold); //Defini le seuil de luminosité au dessus duquel le blob est detecté
}

void draw()
{
  background(0);
  //depth = loadImage("depth.jpg");
  
  //Detect
  fpsTracker.run(frameRate);
  image(fpsTracker.getImageTracker(), 0, height - fpsTracker.h);

  image(depth, 0, 0, depth.width, depth.height); //affiche l'image source
  img.copy(depth, 0, 0, depth.width, depth.height, 0, 0, img.width, img.height); //copy l'image source dans un texture
  fastblur(img, 2); //Floute la texture
  image(img, depth.width, 0, depth.width/2, depth.height/2); //affiche la texture
  
  fill(255);
  text("Nombre de Blobs : " + getNbBlobs(), depth.width +10, depth.height/2 + 20);
  text("Threshold : "+threshold, depth.width + 10, depth.height/2 + 40);


  theBlobDetection.computeBlobs(img.pixels); //analyse la texture pour trouver les blob
  drawBlobsAndEdges(depth); //dessine les blob
}

