#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform sampler2D texture02;
uniform sampler2D texture03;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main() 
{
	
	vec4 depth = texture2D(texture, vertTexCoord);
	vec4 body = texture2D(texture02, vertTexCoord);
	vec4 depthDetail = texture2D(texture03, vertTexCoord);
	vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
	float depthDetailValue = depthDetail.w;
	float depthValue = depthDetail.w;//depth.w

	if(body != vec4(1.0, 1.0, 1.0, 1.0))
	{
		//depthValue 
		color = vec4(1.0 - depthValue, 1.0 - depthValue ,1.0 - depthValue, 1.0);
	}
	else
	{

	}

 	gl_FragColor = color;//depth *  body;
} 