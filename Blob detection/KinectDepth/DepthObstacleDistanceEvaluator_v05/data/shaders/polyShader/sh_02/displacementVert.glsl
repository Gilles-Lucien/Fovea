//Depthmap displacement vertex shader & per-pixelLighting - a.0.0
uniform mat4 modelview;
uniform mat4 transform;
uniform mat3 normalMatrix;

//lights
uniform vec4 lightPosition;
uniform vec3 lightNormal;

attribute vec4 vertex;
attribute vec4 color;
attribute vec3 normal;

varying vec4 vertColor;
varying vec3 ecNormal;
varying vec3 lightDir;

void main()
{
	vec3 ecVertex = vec3(modelview * vertex);
	ecNormal = normalize(normalMatrix * normal);
	lightDir = normalize(lightPosition.xyz - ecVertex);
	vertColor = color;
	gl_Position = transform * vertex;
}