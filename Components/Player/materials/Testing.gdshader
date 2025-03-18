//THIS SHADER MUST BE APPLIED TO A QUAD (MeshInstance) WITH A SIZE OF (2, 2)
//Extra Cull Margin on the quad should be turned up all the way!

shader_type spatial;
render_mode unshaded,depth_draw_always,depth_test_disabled;
uniform sampler2D SCREEN_TEXTURE:hint_screen_texture;
uniform sampler2D DEPTH_TEXTURE:hint_depth_texture;
uniform float outline_bias : hint_range(-10, 10) = 0;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}



void fragment() {
	ALBEDO = vec3(0.);
	
	float depth_at = texture(DEPTH_TEXTURE,SCREEN_UV).r;
	
	vec2 screen_size = vec2(textureSize(SCREEN_TEXTURE, 0));
	
	float px = 0.5/screen_size.x;
	float py = 0.5/screen_size.y;
	
	//calculate outlines
	
	float d=(
		texture(DEPTH_TEXTURE,SCREEN_UV+vec2(px,py)).r+
		texture(DEPTH_TEXTURE,SCREEN_UV-vec2(px,py)).r-
		texture(DEPTH_TEXTURE,SCREEN_UV+vec2(0,py)).r-
		texture(DEPTH_TEXTURE,SCREEN_UV-vec2(0,py)).r+
		texture(DEPTH_TEXTURE,SCREEN_UV+vec2(-px,py)).r+
		texture(DEPTH_TEXTURE,SCREEN_UV-vec2(-px,py)).r-
		texture(DEPTH_TEXTURE,SCREEN_UV+vec2(px,0)).r-
		texture(DEPTH_TEXTURE,SCREEN_UV-vec2(px,0)).r
	)*4.0;
	
	//float c=length(
		//texture(SCREEN_TEXTURE,SCREEN_UV+vec2(px,py))+
		//texture(SCREEN_TEXTURE,SCREEN_UV-vec2(px,py))-
		//texture(SCREEN_TEXTURE,SCREEN_UV+vec2(0,py))-
		//texture(SCREEN_TEXTURE,SCREEN_UV-vec2(0,py))+
		//texture(SCREEN_TEXTURE,SCREEN_UV+vec2(-px,py))+
		//texture(SCREEN_TEXTURE,SCREEN_UV-vec2(-px,py))-
		//texture(SCREEN_TEXTURE,SCREEN_UV+vec2(px,0))-
		//texture(SCREEN_TEXTURE,SCREEN_UV-vec2(px,0))
	//);
	
	ALPHA = float(depth_at<0.9?d<-0.1:d<-0.001);
	
}

//Written by Warren Jennings