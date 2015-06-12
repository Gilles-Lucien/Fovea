//Depthmap displacement vertex shader & per-pixelLighting - a.0.0
varying vec4 vertColor;
varying vec3 ecNormal;
varying vec3 lightDir;

uniform vec3 colorTint;
uniform float alpha;

void main()
{
	vec3 direction = normalize(lightDir);
	vec3 normal = normalize(ecNormal);
	float intensity = max(0.5, dot(direction, normal));
	vec4 lightShadow = vec4(intensity, intensity, intensity, 1.0);
	vec4 color = vec4(colorTint.x, colorTint.y, colorTint.z, alpha);

	gl_FragColor = color * vertColor * lightShadow; 
}