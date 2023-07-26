shader_type canvas_item;

uniform vec3 old_colors[64];
uniform vec3 new_colors[64];


void convert(inout vec4 color, vec3 starting_colors, vec3 resulting_colors) {
	if (color.rgb * 255.0 == starting_colors.rgb) {
		color.rgb = resulting_colors/255.0;
	}
}


void fragment() {

	for (int i = 0; i < old_colors.length(); i++){
		convert(COLOR, old_colors[i], new_colors[i]);
	}
//	COLOR.rgb = old_colors[0];
}
