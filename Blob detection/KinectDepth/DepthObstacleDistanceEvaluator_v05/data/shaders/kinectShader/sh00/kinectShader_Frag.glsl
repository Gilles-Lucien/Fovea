#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform sampler2D texture02;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main() 
{
	
	vec4 depth = texture2D(texture, vertTexCoord);
	vec4 body = texture2D(texture02, vertTexCoord);
	vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
	float depthValue =  depth.w;

	if(body != vec4(1.0, 1.0, 1.0, 1.0))
	{
		if(depthValue <= 0.25)
		{
				depthValue = 1.0; //correction du depth map lorsque de l'utilisateur est en dehors du seuil
		}
		color = vec4(1.0, 1.0, 1.0, 1.0) * (1.0 - depthValue);//vec4(1.0 - depthValue, 1.0 - depthValue, 1.0 - depthValue, 1.0);
			
	}
	else
	{

	}

 	gl_FragColor = color;//depth *  body;
} 