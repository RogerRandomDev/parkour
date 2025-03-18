shader_type canvas_item;

uniform int max_value=4;
uniform int current_value=0;

uniform vec3 background_color: source_color =vec3(0,0.18,0.18);
uniform vec3 selected_color: source_color =vec3(0.,1.,1.);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float progress=(float(current_value)+0.5)/float(max_value);
	float max_point=float(current_value+1)/float(max_value);
	
	COLOR.rgb=mix(selected_color,background_color,float(abs(UV.x-progress)>0.45/float(max_value)||abs(UV.y-0.5)>0.35));
	
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
