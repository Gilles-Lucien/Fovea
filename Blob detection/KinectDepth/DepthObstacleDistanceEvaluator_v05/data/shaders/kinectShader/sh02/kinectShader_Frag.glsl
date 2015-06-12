#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform sampler2D texture02;

//CC
uniform float inBlack;
uniform float inGamma;
uniform float inWhite; 
uniform float outBlack;
uniform float outWhite;
uniform float bias;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main() 
{
	
	vec4 depth = texture2D(texture, vertTexCoord, bias);
	vec4 body = texture2D(texture02, vertTexCoord);
	vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
	vec4 outPixelRGB = vec4(0.0, 0.0, 0.0, 1.0);
	float depthValue =  depth.w; //-1.0

	

	if(body != vec4(1.0, 1.0, 1.0, 1.0) && depthValue != 0.0)
	{
		color = vec4(1.0, 1.0, 1.0, 1.0) - depthValue;
		//color = smoothstep( vec4(0.0, 0.0, 0.0, 1.0), depthValue, 0.5);// * //vec4(1.0 - depthValue, 1.0 - depthValue, 1.0 - depthValue, 1.0);	
		//color =  mix( vec4(1.0, 0.0, 0.0, 1.0), vec4(0.0, 0.0, 0.0, 1.0), depthValue);
	}
	else
	{
		color = vec4(0.0, 0.0, 0.0, 1.0);
	}

	outPixelRGB = (pow(((color * 255.0) - inBlack) / (inWhite - inBlack), inGamma) * (outWhite - outBlack) + outBlack) / 255.0;

 	gl_FragColor = outPixelRGB;//depth *  body;
} 