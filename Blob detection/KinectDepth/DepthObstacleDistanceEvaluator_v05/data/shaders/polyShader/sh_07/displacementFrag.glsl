uniform sampler2D uvChecker;
uniform sampler2D displacementMap;

//In variables from Vertex Shader
varying vec4 vertColor;
varying vec4 vertTexCoord00;
varying vec4 vertTexCoord01;
varying vec3 ecNormal;
varying vec3 lightDir;
varying vec3 lightColor;
varying vec3 normalizeVertex;
varying vec4 lightColorFinal;

//Shader properties / parameters
uniform vec3 colorTint;
uniform float alpha;
uniform float Kd; //Diffuse Reflectivity
uniform float Ld; //lightSource intensity

void main()
{
	vec4 debugIncColor = vec4(1, 1, 1, 1);
	vec4 dv = texture2D(displacementMap, vertTexCoord00);
	vec4 uv = texture2D(uvChecker, vertTexCoord01);
	float mixValue = uv.z;//*2.5;//*4.0;
	debugIncColor = mix(vec4(1.0), vec4(1.0) * (uv * 1), mixValue);
	vec3 direction = normalize(lightDir);

	vec3 normal = normalize(ecNormal);
	
	float intensity = max(0.0, dot(direction, normal)) * Kd * Ld;
	vec4 lightShadow = vec4(lightColor.x * intensity, lightColor.y * intensity, lightColor.z * intensity, 1.0) + (uv * 0.25);

	vec4 color = vec4(colorTint.x, colorTint.y, colorTint.z, alpha);
	
	
	gl_FragColor = vertColor * color * lightShadow;// * debugIncColor;//texture2D(displacementMap, vertTexCoord.st);//* texture2D(uvChecker, vertTexCoord.st);// vertColor * * debugIncColor ;// * texture2D(uvChecker, vertTexCoord.st); //* debugIncColor
}