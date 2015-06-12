import KinectPV2.*;
import KinectPV2.KJoint;

class Kinect
{
  PApplet context;
  KinectPV2 kinect;

  int[] rawDepth;
  int[] rawDepthMask;
  int[] rawColor;
  int[] rawInfared;
  int[] rawBody;
  int[] rawLongExposure;
  int[] rawDataPointCloud;

  //Distance Threashold
  float maxD;
  float minD;

  //Mesh + OffscreenTexture
  float meshMargin;
  PShape mesh;
  PGraphics kinectOffscreen;
  PShader kinectShader;
  float inputBlack, inputWhite, inputGamma;
  float outputBlack, outputWhite;
  float bias;

  //Blur
  PShader blur;
  PGraphics pass1, pass2;
  int blurSize;
 float blurSigma;

  Kinect(PApplet context_)
  {
    context = context_;
    initKinect();
    initBlurShading();
  }

  void initKinect()
  {
    maxD = 1f; //distance in meters : 0.5 min distance near and 4.5 max distance far  (profondeur du depthmap)
    minD = 0.5f;

    kinect = new KinectPV2(context);

    //enabled informations data
    kinect.enableColorImg(true);
    kinect.enableDepthImg(true);
    kinect.enableInfraredImg(true);
    kinect.enableBodyTrackImg(true);
    kinect.enableLongExposureInfraredImg(true);

    //enabled raw data
    kinect.activateRawColor(true);
    kinect.activateRawDepth(true);
    kinect.activateRawDepthMaskImg(true);
    kinect.activateRawInfrared(true);
    kinect.activateRawBodyTrack(true);
    kinect.activateRawLongExposure(true);

    //Enable point cloud
    kinect.enablePointCloud(true);

    //init object
    kinect.init();

    //SetThreshold
    setThreshold(minD, maxD);

    //offscreen
    meshMargin = 20;    
    inputBlack = 0; 
    inputWhite = 1; 
    inputGamma = 255;
    outputBlack = 0; 
    outputWhite = 255;
    bias = 0.5;
    kinectOffscreen = createGraphics(kinect.getDepthImage().width, kinect.getDepthImage().height, P3D);
    kinectShader = loadShader("shaders/kinectShader/sh03/kinectShader_Frag.glsl", "shaders/kinectShader/sh03/kinectShader_Vert.glsl");
    mesh = createShape();
    computeKinectMesh();
  }

  void initBlurShading()
  {
    blurSize = 9;
    blurSigma = 5.0f;
    blur = loadShader("shaders/kinectShader/blur.glsl");
    blur.set("blurSize", 9);
    blur.set("sigma", 5.0f);  

    pass1 = createGraphics(kinect.getDepthImage().width, kinect.getDepthImage().height, P3D);
    pass1.noSmooth();  

    pass2 = createGraphics(kinect.getDepthImage().width, kinect.getDepthImage().height, P3D);
    pass2.noSmooth();
  }

  //computation
  void computeKinectMesh()
  {
    mesh.beginShape(TRIANGLE);
    mesh.noStroke();
    mesh.textureMode(NORMAL);
    mesh.texture(kinect.getPointCloudDepthImage());
    //face00
    //mesh.stroke(255, 0, 0); 
    mesh.vertex(meshMargin, meshMargin, 0, 0);
    // mesh.stroke(0, 255, 0); 
    mesh.vertex(kinectOffscreen.width - meshMargin, meshMargin, 1, 0);
    // mesh.stroke(0, 0, 255); 
    mesh.vertex(meshMargin, kinectOffscreen.height - meshMargin, 0, 1);

    //face01
    //  mesh.stroke(0, 0, 255); 
    mesh.vertex(meshMargin, kinectOffscreen.height - meshMargin, 0, 1);
    //  mesh.stroke(0, 255, 0); 
    mesh.vertex(kinectOffscreen.width - meshMargin, meshMargin, 1, 0);
    //  mesh.stroke(255, 0, 0); 
    mesh.vertex(kinectOffscreen.width - meshMargin, kinectOffscreen.height - meshMargin, 1, 1);
    mesh.endShape();
  }

  void computeKinectOffscreenTexture()
  {
   // bindTexture("texture02", kinect.getBodyTrackImage());
    //bindColorCorrection();
    //bindTexture("texture03", kinect.getDepthImage()); //used width sh01/shaderName
    kinectOffscreen.beginDraw();
    kinectOffscreen.background(0);
    kinectOffscreen.shader(kinectShader);
    kinectOffscreen.shape(mesh);
    kinectOffscreen.resetShader();
    kinectOffscreen.endDraw();
  }

  void blurPass()
  {
    bindBlurParameters();
    // Applying the blur shader along the vertical direction   
    blur.set("horizontalPass", 0);
    pass1.beginDraw();            
    pass1.shader(blur);  
    pass1.image(kinectOffscreen, 0, 0);
    pass1.endDraw();

    // Applying the blur shader along the horizontal direction      
    blur.set("horizontalPass", 1);
    pass2.beginDraw();            
    pass2.shader(blur);  
    pass2.image(pass1, 0, 0);
    pass2.endDraw();
  }

  void computeRawData()
  {
    rawDepth = kinect.getRawDepth();
    rawDepthMask = kinect.getRawDepthMask();
    rawColor = kinect.getRawColor();
    rawInfared = kinect.getRawInfrared();
    rawBody = kinect.getRawBodyTrack();
    rawLongExposure = kinect.getRawLongExposure();
    rawDataPointCloud = kinect.getRawPointCloudDepth();
  }

  void bindColorCorrection()
  {

    kinectShader.set("inBlack", inputBlack);
    kinectShader.set("inGamma", inputGamma);
    kinectShader.set("inWhite", inputWhite);

    kinectShader.set("outBlack", outputBlack);
    kinectShader.set("outWhite", outputWhite);

    kinectShader.set("bias", bias);
  }
  
  void bindBlurParameters()
  {
     blur.set("blurSize", blurSize);
    blur.set("sigma", blurSigma); 
  }

  //Display
  void showDebug(float targetWidth, float x, float y)
  {
    float scale = kinect.getColorImage().width / targetWidth;
    float scaleDepth =  kinect.getDepthImage().width / ((kinect.getColorImage().width / scale)/2);
    float y0 = kinect.getColorImage().height / scale;
    float y1 = kinect.getDepthImage().height / scaleDepth;

    image(getColorImage(), x, y, getColorImage().width / scale, getColorImage().height / scale);
    image(getDepthImage(), x, y + y0, getDepthImage().width / scaleDepth, getDepthImage().height / scaleDepth);
    image(getInfraredImage(), x + getDepthImage().width / scaleDepth, y + y0, getInfraredImage().width / scaleDepth, getInfraredImage().height / scaleDepth);
    image(getBodyTrackImage(), x, y + y0 + y1, getBodyTrackImage().width / scaleDepth, getBodyTrackImage().height / scaleDepth);
    image(getPointCloudDepthImage(), x+getDepthImage().width / scaleDepth, y + y0 + y1, getPointCloudDepthImage().width / scaleDepth, getPointCloudDepthImage().height / scaleDepth);

    //finalImage
    image(getKinectOffscreenTexture(), targetWidth, 0);
  }

  //methode get
  PImage getImageFromRawData(int[] pixelsData, int PIwidth, int PIheight)
  {
    PImage depthTest = createImage(PIwidth, PIheight, ARGB);
    try {
      depthTest.pixels = pixelsData;
    }
    catch(Exception e)
    {
      println("Size is not correct. Max pixel wanted : "+(PIwidth * PIheight)+" Length of pixel data : "+pixelsData.length);
    }
    return depthTest;
  }

  PImage getMultipliedImageFromRawDatas(int[] pixelsData00, int[] pixelsData01, int PIwidth, int PIheight)
  {
    PImage depthTest = createImage(PIwidth, PIheight, RGB);
    try {
      for (int i = 0; i < depthTest.width; i++)
      {
        for (int j = 0; j < depthTest.height; j++)
        {
          int loc = j * depthTest.width + i;
          depthTest.pixels[loc] = pixelsData00[loc] * pixelsData01[loc];
        }
      }
    }
    catch(Exception e)
    {
      println("Size is not correct. Max pixel wanted : "+(PIwidth * PIheight)+" Length of pixel data 00 : "+pixelsData00.length+" Length of pixel data 01 : "+pixelsData01.length);
    }
    return depthTest;
  }

  PImage getColorImage()
  {
    return kinect.getColorImage();
  }

  PImage getDepthImage()
  {
    return kinect.getDepthImage();
  }

  PImage getInfraredImage()
  {
    return kinect.getInfraredImage();
  }

  PImage getBodyTrackImage()
  {
    return kinect.getBodyTrackImage();
  }

  PImage getPointCloudDepthImage()
  {
    return kinect.getPointCloudDepthImage();
  }

  PImage getKinectOffscreenTexture()
  {
    PImage kinectBuffer = pass2.get();
    return kinectBuffer;
  }
  
  PImage getOriginalKinectOffscreenTexture()
  {
    PImage kinectBuffer = kinectOffscreen.get();
    return kinectBuffer;
  }

  //Set
  void setThreshold(float min, float max)
  {
    minD = min;
    maxD = max;
    kinect.setLowThresholdPC(minD);
    kinect.setHighThresholdPC(maxD);
  }

  void bindTexture(String variableName, PImage tex)
  {
    kinectShader.set(variableName, tex);
  }
}

