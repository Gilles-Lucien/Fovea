#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform sampler2D texture02;

//CC
uniform float inBlack;
uniform float inGamma;
uniform float inWhite; 
uniform float outBlack;
uniform float outWhite;
uniform float bias;

varying vec4 vertColor;
varying vec4 vertTexCoord;


void main() 
{
  vec4 depth = texture2D(texture, vertTexCoord);
  vec4 finalColor;
  if(depth.w > 0.0)
  {
  	finalColor = vec4(1.0 - depth.w, 1.0 - depth.w, 1.0 - depth.w, 1.0);
  }
  else
  {
  	finalColor = vec4(0.0, 0.0, 0.0, 1.0);
  }
  gl_FragColor = finalColor; 
} 