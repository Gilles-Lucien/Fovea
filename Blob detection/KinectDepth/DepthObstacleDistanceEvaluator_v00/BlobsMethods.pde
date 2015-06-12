
void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges, boolean drawCenter, boolean sampleColor, PImage source)
{
  //Pour chacun de blob dectecté par l'objet blobDetection
  for (int n=0; n<theBlobDetection.getBlobNb (); n++)
  {
    Blob b = theBlobDetection.getBlob(n); //Soit b le blob à l'index n du tableau de blob
    if (b!=null) //Si blob existe
    {
      // Dessine les contour du blob 
      if (drawEdges)
      {
        pushStyle();
        strokeWeight(1);
        stroke(0, 255, 0);

        //Pour chaque blob nous récupérer ses coordonées de contours
        beginShape(LINES);
        for (int m=0; m<b.getEdgeNb (); m++)
        {
          EdgeVertex eA = b.getEdgeVertexA(m); //Coordonées de départ du contour
          EdgeVertex eB = b.getEdgeVertexB(m); //Coordonées d'arrivée du contour
          if (eA !=null && eB !=null)
            vertex(eA.x*source.width, eA.y*source.height);
          vertex(eB.x*source.width, eB.y*source.height);
        }
        endShape();
        popStyle();
      }

      // Dessine le rectangle dans lequel est inclu le blob
      if (drawBlobs)
      {
        pushStyle();
        strokeWeight(1);
        stroke(255, 0, 0);
        noFill();
        rect(b.xMin*source.width, b.yMin*source.height, b.w*source.width, b.h*source.height);
        popStyle();
      }

      //Dessine le centre et l'hypotenuse du blob
      if (drawCenter)
      {
        float cx = (b.xMin + ((b.xMax - b.xMin)/2)) * source.width;
        float cy = (b.yMin + ((b.yMax - b.yMin)/2)) * source.height;
        pushStyle();
        fill(0, 0, 255);
        noStroke();
        ellipse(cx, cy, 10, 10);
        stroke(0, 0, 255);
        line(b.xMin * source.width, b.yMin * source.height, b.xMax * source.width, b.yMax * source.height); 
        popStyle();
      }

      if (sampleColor)
      {
        ArrayList<PVector> blobShape =  new ArrayList<PVector>();
        for (int m=0; m<b.getEdgeNb (); m++)
        {
          EdgeVertex eA = b.getEdgeVertexA(m); //Coordonées de départ du contour
          EdgeVertex eB = b.getEdgeVertexB(m); //Coordonées d'arrivée du contour
          PVector va = new PVector(eA.x*source.width, eA.y*source.height);
          PVector vb = new PVector(eB.x*source.width, eB.y*source.height);
          blobShape.add(va);
          blobShape.add(vb);
        }
        
        sampleColorsBlob(b.xMin*source.width, b.xMax*source.width, b.yMin*source.height, b.yMax*source.height, 20, blobShape);
        //blobShape.clear();
      }
    }
  }
}

void sampleColorsBlob(float xStart, float xEnd, float yStart, float yEnd, float res, ArrayList<PVector> blobPolyShape)
{
  float gridWidth = xEnd - xStart;
  float gridHeight = yEnd - yStart;
  int resPerWidth = floor(gridWidth / res);
  int resPerHeight = floor(gridHeight / res);

  pushStyle();
  for (int xi = 0; xi < resPerWidth; xi++)
  {
    for (int yi = 0; yi < resPerHeight; yi++)
    {
      float x = xStart + (res * xi) + res/2;
      float y = yStart + (res * yi) + res/2;

      PVector pixelSample = new PVector(x, y);

      /*if (pixelInPoly(blobPolyShape, pixelSample))
      {*/
        noFill();
        stroke(255, 0, 255);
        rectMode(CENTER);
        rect(x, y, res, res);
      //}
    }
  }
  popStyle();
}

boolean pixelInPoly(ArrayList<PVector> verts, PVector pos) {
  int i, j;
  boolean c=false;
  int sides = verts.size();
  for (i=0, j=sides-1; i<sides; j=i++) {
    if (( ((verts.get(i).y <= pos.y) && (pos.y < verts.get(j).y)) || ((verts.get(j).y <= pos.y) && (pos.y < verts.get(i).y))) &&
      (pos.x < (verts.get(j).x - verts.get(i).x) * (pos.y - verts.get(i).y) / (verts.get(j).y - verts.get(i).y) + verts.get(i).x)) {
      c = !c;
    }
  }
  return c;
}
// ==================================================
// Super Fast Blur v1.1
// by Mario Klingemann 
// <http://incubator.quasimondo.com>
// ==================================================
void fastblur(PImage img, int radius)
{
  if (radius<1) {
    return;
  }
  int w=img.width;
  int h=img.height;
  int wm=w-1;
  int hm=h-1;
  int wh=w*h;
  int div=radius+radius+1;
  int r[]=new int[wh];
  int g[]=new int[wh];
  int b[]=new int[wh];
  int rsum, gsum, bsum, x, y, i, p, p1, p2, yp, yi, yw;
  int vmin[] = new int[max(w, h)];
  int vmax[] = new int[max(w, h)];
  int[] pix=img.pixels;
  int dv[]=new int[256*div];
  for (i=0; i<256*div; i++) {
    dv[i]=(i/div);
  }

  yw=yi=0;

  for (y=0; y<h; y++) {
    rsum=gsum=bsum=0;
    for (i=-radius; i<=radius; i++) {
      p=pix[yi+min(wm, max(i, 0))];
      rsum+=(p & 0xff0000)>>16;
      gsum+=(p & 0x00ff00)>>8;
      bsum+= p & 0x0000ff;
    }
    for (x=0; x<w; x++) {

      r[yi]=dv[rsum];
      g[yi]=dv[gsum];
      b[yi]=dv[bsum];

      if (y==0) {
        vmin[x]=min(x+radius+1, wm);
        vmax[x]=max(x-radius, 0);
      }
      p1=pix[yw+vmin[x]];
      p2=pix[yw+vmax[x]];

      rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
      gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
      bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
      yi++;
    }
    yw+=w;
  }

  for (x=0; x<w; x++) {
    rsum=gsum=bsum=0;
    yp=-radius*w;
    for (i=-radius; i<=radius; i++) {
      yi=max(0, yp)+x;
      rsum+=r[yi];
      gsum+=g[yi];
      bsum+=b[yi];
      yp+=w;
    }
    yi=x;
    for (y=0; y<h; y++) {
      pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
      if (x==0) {
        vmin[y]=min(y+radius+1, hm)*w;
        vmax[y]=max(y-radius, 0)*w;
      }
      p1=x+vmin[y];
      p2=x+vmax[y];

      rsum+=r[p1]-r[p2];
      gsum+=g[p1]-g[p2];
      bsum+=b[p1]-b[p2];

      yi+=w;
    }
  }
}

