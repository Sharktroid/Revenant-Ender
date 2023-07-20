shader_type canvas_item;

/// Extra code inserted here by the unit's script
// Anything between the three forward slashes (/) gets removed
// This version is for the editor
const mat3 conversion_array[] = {mat3(vec3(56, 56, 144), vec3(96, 40, 32), vec3(0)), 
	mat3(vec3(56, 80, 224), vec3(168, 48, 40), vec3(0)), 
	mat3(vec3(40, 160, 248), vec3(224, 16, 16), vec3(0)), 
	mat3(vec3(24, 240, 248), vec3(248, 80, 72), vec3(0)), 
	mat3(vec3(232, 16, 24), vec3(56, 208, 48), vec3(0)), 
	mat3(vec3(88, 72, 120), vec3(104, 72, 96), vec3(0)), 
	mat3(vec3(216, 232, 240), vec3(224, 224, 224), vec3(0)), 
	mat3(vec3(144, 184, 232), vec3(192, 168, 184), vec3(0))};

// End of extra code ///


void convert(inout vec4 color, vec3 starting_colors, vec3 resulting_colors) {
	if (color.rgb * 255.0 == starting_colors.rgb) {
		color.rgb = resulting_colors/255.0;
	}
}


void fragment() {
	for (int i = 0; i < conversion_array.length(); i++){
		convert(COLOR, conversion_array[i][0], conversion_array[i][1]);
	}
	//GBA_color(COLOR);
}
