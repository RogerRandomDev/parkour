shader_type spatial;
render_mode unshaded,cull_disabled;
uniform sampler2D SCREEN_TEXTURE:hint_screen_texture;
uniform float progress:hint_range(0.,1.);
void fragment() {
	float dist=distance(abs(UV.x-0.5),progress);
	ALBEDO=texture(SCREEN_TEXTURE,SCREEN_UV+vec2(dist)*NORMAL.zy/VIEWPORT_SIZE * 16.).rgb;
}
