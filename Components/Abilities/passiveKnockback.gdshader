shader_type spatial;
render_mode unshaded,cull_disabled,ambient_light_disabled;
uniform sampler2D SCREEN_TEXTURE:hint_screen_texture;
uniform float distortionAmount=16.;
void fragment() {
	vec2 rippleStrength=distance(mod(NORMAL.z*10.+TIME,1.),1.)*distortionAmount/VIEWPORT_SIZE;
	ALBEDO.rgb=texture(SCREEN_TEXTURE,SCREEN_UV+NORMAL.xy*rippleStrength).rgb+vec3(0.,0.,0.5);
}
