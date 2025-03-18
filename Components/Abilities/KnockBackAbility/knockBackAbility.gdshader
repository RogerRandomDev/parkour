shader_type spatial;
render_mode unshaded;
//level of distortion caused by ripples
uniform float rippleStrength;
//how far the ripple has moved from the center
uniform float rippleProgress=0.;


uniform sampler2D SCREEN_TEXTURE:hint_screen_texture;

void fragment() {
	
	//ALBEDO.rgb=texture(SCREEN_TEXTURE,SCREEN_UV).rgb;
	float modDist=distance(mod(abs(NORMAL.z*8.),1.),1.);
	vec2 rippleDir=NORMAL.xy*modDist/VIEWPORT_SIZE*rippleStrength;
	ALBEDO=(texture(SCREEN_TEXTURE,SCREEN_UV+rippleDir).rgb+vec3(0.,0.,.25))*(dot(NORMAL,VIEW));
	ALPHA=clamp((1.-rippleProgress),0.,1.);
}
