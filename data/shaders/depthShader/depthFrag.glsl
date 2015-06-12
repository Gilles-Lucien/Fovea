#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif
uniform vec4 screen;
varying vec4 vertColor;

void main() {
   float depth = smoothstep(screen.z, screen.w, gl_FragCoord.z / gl_FragCoord.w);
   gl_FragColor = vec4(1.0 - depth, 1.0 - depth, 1.0 - depth, 1.0); //vec4(gl_FragCoord.x / screen.x, gl_FragCoord.y / screen.y, 1.0, 1.0 - depth);
}