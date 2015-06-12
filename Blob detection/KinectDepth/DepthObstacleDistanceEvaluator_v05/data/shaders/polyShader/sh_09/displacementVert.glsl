//Compute Screen-Space Texture Coordinates
//Based on : http://www.songho.ca/opengl/gl_transform.html && http://diaryofagraphicsprogrammer.blogspot.fr/2008/09/calculating-screen-space-texture.html
#define PROCESSING_TEXTLIGHT_SHADER

//Matrix
uniform mat4 modelview;
uniform mat4 transform;
uniform mat3 normalMatrix;
uniform mat4 texMatrix;

//lights
uniform int lightCount;
uniform vec4 lightPosition[8];
uniform vec3 lightNormal[8];
uniform vec3 lightFalloff[8];

//Mesh Attributes
attribute vec4 vertex;
attribute vec3 normal;
attribute vec4 color;
attribute vec2 texCoord;

//Shader properties / parameters
uniform vec3 origin;
uniform sampler2D displacementMap;
uniform float displaceStrength;
uniform sampler2D uvChecker;
uniform vec2 viewport;
uniform float textureRatio;
uniform bool isDepthForBuffer;

//Out variables for FragmentShader
varying vec4 vertColor;
varying vec4 vertTexCoord00;
varying vec4 vertTexCoord01;
varying vec4 ecVertex;
varying vec3 ecNormal;
varying vec3 lightDir[8];
varying float fallOff[8];
varying vec3 normalizeVertex;
varying vec3 rimVertColor;

//constant
const float one_float = 1.0;

float falloffFactor(vec3 lightPos, vec3 vertPos, vec3 coeff) {
  vec3 lpv = lightPos - vertPos;
  vec3 dist = vec3(one_float);
  dist.z = dot(lpv, lpv);
  dist.y = sqrt(dist.z);
  return one_float / dot(dist, coeff);
}

void main()
{
	//Displacement - Define Variable and compute normals for displacement
	vec4 newVertexPos;
	vec3 displacementNormal = vertex - origin;
	displacementNormal = normalize(displacementNormal);
	normalizeVertex = vec3(normalMatrix * normalize(vertex.xyz));
	//Compute uv Projection
	vec4 posProjection = transform * vertex;
	float u = 1.0 / posProjection.w * ((posProjection.x + posProjection.w) * 0.5 + 0.5 * viewport.x * posProjection.w);
	float v = textureRatio / posProjection.w * ((posProjection.w - posProjection.y) * 0.5 + 0.5 * viewport.y * posProjection.w) - 1;
	vertTexCoord00 = texMatrix * vec4(u, 1.0-v, 1.0, 1.0);//* vec4(u, 1.0-v, 1.0, 1.0);
	vertTexCoord01 = texMatrix * vec4(u, v, 1.0, 1.0);
	//compute texture
	vec4 dv = texture2D(displacementMap, vertTexCoord00);
	vec4 dv01 = texture2D(uvChecker, vertTexCoord01);
	//compute displacement strength
	float df = (0.30*dv.x + 0.59*dv.y + 0.11*dv.z);
	df = df * (displaceStrength * 0.01);
	//compute displacement
	if(normalizeVertex.z > 0.0 &&  dv.w > 0.05)//
	{
		newVertexPos = vertex + vec4(displacementNormal * df * displaceStrength, 0.0); //
	}
	else
	{
		newVertexPos = vertex;
	}
	
	//compute vertex color
	vertColor = color;

	if(!isDepthForBuffer)
	{
		//ligh & rim Computation
		ecVertex = vec4(modelview * newVertexPos);
 		vec3 invertNormalizedecVertex = normalize(-ecVertex);
 		vec3 n;

		if(dv.x > 0.0)
		{
			ecNormal = normalize(normalMatrix * displacementNormal);
 			n = normalize(mat3(modelview) * displacementNormal);      // convert normal to view space
 		}
		else
		{
			ecNormal = normalize(normalMatrix * normal);
 			n = normalize(mat3(modelview) * normal);      // convert normal to view space
		}

	 	for(int i = 0 ;i < lightCount ;i++) { 
    		lightDir[i] = normalize(lightPosition[i].xyz - ecVertex);
   		 	fallOff[i] = falloffFactor(lightPosition[i].xyz, ecVertex, lightFalloff[i]); 
 		}

 		//rimComputation   ;
 		rimVertColor = 1.0 - max(dot(invertNormalizedecVertex, n), 0.0);
	}
	
	
	//Compute MVP
	vec4 vertMVP = vec4(transform * newVertexPos);
	gl_Position = vertMVP;//transform * vertex;//newVertexPos;
}