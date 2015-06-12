//Depthmap displacement vertex shader & per-pixelLighting - a.0.0
varying vec4 vertColor;
varying vec3 ecNormal;
varying vec3 lightDir;
varying vec3 normalizeVertex;

uniform vec3 colorTint;
uniform float alpha;
uniform float Kd; //Diffuse Reflectivity
uniform float Ld; //lightSource intensity

void main()
{
	vec3 direction = normalize(lightDir);
	vec3 normal = normalize(ecNormal);
	float intensity = max(0.0, dot(direction, normal)) * Kd * Ld;
	vec4 lightShadow = vec4(intensity, intensity, intensity, 1.0);
	vec4 color = vec4(colorTint.x, colorTint.y, colorTint.z, alpha);

	vec4 debugIncColor = vec4(1, 1, 1, 1);
	if(normalizeVertex.z > 0.5)
	{
		debugIncColor = vec4(normalizeVertex.x, normalizeVertex.y, normalizeVertex.z, 1);
	}
	else
	{
		//debugIncColor = vec4(1, 1, 1, 1);
	}


	gl_FragColor = color * vertColor * lightShadow * debugIncColor; 
}