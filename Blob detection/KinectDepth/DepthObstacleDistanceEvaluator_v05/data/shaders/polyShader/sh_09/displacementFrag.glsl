uniform sampler2D uvChecker;
uniform sampler2D displacementMap;
uniform int lightCount;// = 8;
uniform vec3 lightNormal[8];
uniform vec4 lightPosition[8];
// diffuse is the color element of the light
uniform vec3 lightDiffuse[8];
uniform vec3 lightFalloff[8];

//material
uniform vec3 kd;//Diffuse reflectivity
uniform vec3 ka;//Ambient reflectivity
uniform vec3 ks;//Specular reflectivity
uniform float shininess;//shine factor
uniform vec3 emissive;

//fog
uniform float fogMinDist;
uniform float fogMaxDist;
uniform vec3 fogColor;

//rim
uniform vec4 rimColor;
uniform float rimPower;

//depthBuffer
uniform vec4 screen;
uniform bool isDepthForBuffer;

//In variables from Vertex Shader
varying vec4 vertColor;
varying vec4 vertTexCoord00;
varying vec4 vertTexCoord01;
varying vec4 ecVertex;
varying vec3 ecNormal;
varying vec3 lightDir[8];
varying float fallOff[8];
varying vec3 normalizeVertex;
varying vec4 lightColorFinal;
varying vec3 rimVertColor;

vec3 ads(vec3 dir, vec3 color)
{
	vec3 n = normalize(ecNormal);
	vec3 s = normalize(dir);
	vec3 v = normalize(-ecVertex.xyz);
	vec3 r = reflect(-s, n);
	vec3 h = normalize(v + s);
	float intensity = max(0.0, dot(s, n));

	//return color * intensity * (ka + kd * max(dot(s, n), 0.0) + ks * pow(max(dot(r, v), 0.0), shininess));
	return color * intensity * (ka + kd * max(dot(s, ecNormal), 0.0) + ks * pow(max(dot(h, n), 0.0), shininess));
}

void main()
{
	if(!isDepthForBuffer)
	{
		vec4 dv = texture2D(displacementMap, vertTexCoord00);
		vec4 uv = texture2D(uvChecker, vertTexCoord01);

		float mixValue = uv.z;//*2.5;//*4.0;
		//fog
		float dist = length(ecVertex.xyz);
		float fogFactor = (fogMaxDist - dist) / (fogMaxDist - fogMinDist);
		fogFactor = clamp(fogFactor, 0.0, 1.0);


		//lights
		vec4 lightColor;
		
		for(int i = 0 ; i <  lightCount ; i++) 
		{
		  vec3 direction = normalize(lightDir[i]);
		  vec4 coefficient = vec4(lightFalloff[i], 1.0);
		  lightColor += vec4(ads(direction, lightDiffuse[i].xyz), 1.0) * fallOff[i];
		}

	//rim
		vec4 rimsmooth = rimColor * vec4(smoothstep(rimPower, 1.0, rimVertColor), 1.0);
		vec4 final_light_color = (lightColor * (vertColor + (uv * dv *1.5))) + rimsmooth + vec4(emissive, 1.0);//vec4(emissive, 1.0) + lightColor * vertColor + (uv * dv * 1.5);

		vec4 finalColor = mix(vec4(fogColor, 1.0), final_light_color, fogFactor);

		gl_FragColor = finalColor;
	}
	else
	{
		 float depth = smoothstep(screen.z, screen.w, gl_FragCoord.z / gl_FragCoord.w);
  		 gl_FragColor = vec4(gl_FragCoord.x / screen.x, gl_FragCoord.y / screen.y, 1.0, 1.0 - depth);
	}
}