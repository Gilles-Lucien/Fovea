//Depthmap displacement vertex shader & per-vertex Lighting - a.0.0
uniform mat4 modelview;
uniform mat4 transform;
uniform mat3 normalMatrix;

//lights
uniform vec4 lightPosition;
uniform vec3 lightNormal;
uniform vec3 Kd;
uniform vec3 Ld;

attribute vec4 vertex;
attribute vec4 color;
attribute vec3 normal;

varying vec4 vertColor;

void main()
{
	vec3 ecVertex = vec3(modelview * vertex);
	vec3 ecNormal = normalize(normalMatrix * normal);
	vec3 lightDir = normalize(lightPosition.xyz - ecVertex);
	
	float intensity = Ld * Kd * max(dot(lightDir, ecNormal), 0.0);

	vertColor = vec4(intensity, intensity, intensity, 1.0) * color;
	
	gl_Position = transform * vertex;
}