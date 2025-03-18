shader_type canvas_item;

uniform sampler2D Gradient;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR.rgba=texture(Gradient,vec2(UV.y+sin((UV.x+1.0)*PI)*0.1,0.0));
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
