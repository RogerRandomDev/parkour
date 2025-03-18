shader_type spatial;
render_mode cull_disabled;
uniform sampler2D TEXTURE:filter_nearest;

void fragment() {
	ALBEDO=pow(texture(TEXTURE,UV).rgb,vec3(2.2));
}