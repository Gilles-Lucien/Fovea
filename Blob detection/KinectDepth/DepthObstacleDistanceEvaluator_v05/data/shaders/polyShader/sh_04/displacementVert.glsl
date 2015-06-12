//Compute Screen-Space Texture Coordinates
//Based on : http://www.songho.ca/opengl/gl_transform.html && http://diaryofagraphicsprogrammer.blogspot.fr/2008/09/calculating-screen-space-texture.html
#define PROCESSING_LIGHT_SHADER

//Matrix
uniform mat4 modelview;
uniform mat4 transform;
uniform mat3 normalMatrix;
uniform mat4 texMatrix;

//lights
uniform vec4 lightPosition;
uniform vec3 lightNormal;

//Mesh Attributes
attribute vec4 vertex;
attribute vec3 normal;
attribute vec4 color;
attribute vec2 texCoord;

//Out variables for FragmentShader
varying vec4 vertColor;
varying vec4 vertTexCoord00;
varying vec4 vertTexCoord01;
varying vec3 ecNormal;
varying vec3 lightDir;
varying vec3 normalizeVertex;

//Shader properties / parameters
uniform sampler2D displacementMap;
uniform float displaceStrength;
uniform sampler2D uvChecker;
uniform vec2 viewport;
uniform float textureRatio;

void main()
{
	//Displacement
	normalizeVertex = vec3(normalMatrix * normalize(vertex.xyz));
	vec4 newVertexPos;
	vec4 dv;
	float df;
	vec4 posProjection = transform * vertex;
	float u = 1.0 / posProjection.w * ((posProjection.x + posProjection.w) * 0.5 + 0.5 * viewport.x * posProjection.w);
	float v = textureRatio / posProjection.w * ((posProjection.w - posProjection.y) * 0.5 + 0.5 * viewport.y * posProjection.w) - 1;
	vertTexCoord00 = texMatrix * vec4(u, 1.0-v, 1.0, 1.0);
	vertTexCoord01 = texMatrix * vec4(u, v, 1.0, 1.0);

	dv = texture2D(displacementMap, vertTexCoord00);
	df = 0.30*dv.x + 0.59*dv.y + 0.11*dv.z;

	if(normalizeVertex.z > 0.0)
	{
	newVertexPos = vec4(normalize(vertex.xyz) * df * displaceStrength, 0.0) + vertex;
	}
	else
	{
	newVertexPos = vertex;
	}
	vertColor = color;
	//Light Computation
	vec3 vertPos = vec3(modelview * newVertexPos);
	vec3 lightPos = vec3(modelview * lightPosition);
	vec3 newNormal = normalize(newVertexPos.xyz) + normal;
	ecNormal = normalize(normalMatrix * newNormal);//normalize(newVertexPos.xyz));
	lightDir = normalize(lightPos.xyz - vertPos);
	gl_Position = transform * newVertexPos;
}