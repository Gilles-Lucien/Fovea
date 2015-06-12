//Depthmap displacement vertex shader & per-vertex Lighting - a.0.0
varying vec4 vertColor;

uniform vec3 colorTint;
uniform float alpha;

void main()
{

	vec4 color = vec4(colorTint.x, colorTint.y, colorTint.z, alpha);

	gl_FragColor = vertColor; 
}