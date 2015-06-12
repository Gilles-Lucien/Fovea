#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main(void) {
  vec4 color = texture2D(texture, vertTexCoord);
  vec4 finalColor = vec4(1, 1, 1, 1) - color;
  gl_FragColor = finalColor * vertColor;
}
