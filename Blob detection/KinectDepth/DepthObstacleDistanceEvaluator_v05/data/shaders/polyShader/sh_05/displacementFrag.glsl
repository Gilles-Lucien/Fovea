uniform sampler2D uvChecker;
uniform sampler2D displacementMap;

//In variables from Vertex Shader
varying vec4 vertColor;
varying vec4 vertTexCoord;
varying vec3 ecNormal;
varying vec3 lightDir;
varying vec3 normalizeVertex;
varying vec4 lightColorFinal;

//Shader properties / parameters
uniform vec3 colorTint;
uniform float alpha;
uniform float Kd; //Diffuse Reflectivity
uniform float Ld; //lightSource intensity

float find_closest(int x, int  y, float c0)
{
	mat4 dither = mat4(
		1.0,  33.0,  9.0, 41.0,
		49.0, 17.0, 57.0, 25.0,
		13.0, 45.0,  5.0, 37.0,
		61.0, 29.0, 53.0, 21.0 );
	
	float limit = 0.0;
	if(x < 4) {
		if(y >= 4) {
			limit = (dither[x][y-4]+3.0)/65.0;
		} else {
			limit = (dither[x][y])/65.0;
		}
	}
		
	if(x >= 4) {
		if(y >= 4)
			limit = (dither[x-4][y-4]+1.0)/65.0;
		else
			limit = (dither[x-4][y]+2.0)/65.0;
	}
		
	if(c0 < limit)
		return 0.0;
	
	return 1.0;
}


void main()
{
	/*dither*/
	float grayscale = dot(texture2D(displacementMap, vertTexCoord), vec4(0.299, 0.587, 0.114, 0.5));
	vec2 xy = gl_FragCoord * 0.5;
	
	int x = int(mod(xy.x, 8.0));
	int y = int(mod(xy.y, 8.0));
	float final = find_closest(x, y, grayscale);

	/*Lights*/
	vec3 direction = normalize(lightDir);
	vec3 normal = normalize(ecNormal);
	float intensity = max(0.0, dot(direction, normal)) * Kd * Ld;
	vec4 lightShadow = vec4(intensity, intensity, intensity, 1.0);
	vec4 color = vec4(colorTint.x, colorTint.y, colorTint.z, alpha);

	/*Debug*/
	vec4 debugIncColor = vec4(1, 1, 1, 1);
	vec4 dv = texture2D(displacementMap, vertTexCoord);

	float mixValue = dv.z*4.0;
	debugIncColor = mix(vec4(1.0, 1.0, 1.0, 1.0), vec4(0.0, 0.75, 1.0, 1.0) * dv * 3, mixValue);
	

	gl_FragColor =  final * vertColor * color * lightShadow * debugIncColor ;// * texture2D(uvChecker, vertTexCoord.st); //* debugIncColor 
}

