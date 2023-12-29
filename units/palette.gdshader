shader_type canvas_item;

#include "res://gba_color.gdshaderinc"

#define GBA_COLOR

#define MAXIMUM_PALETTE_SIZE 64
uniform vec3 old_colors[MAXIMUM_PALETTE_SIZE];
uniform vec3 new_colors[MAXIMUM_PALETTE_SIZE];


vec3 convert(vec3 color, vec3[MAXIMUM_PALETTE_SIZE] starting_colors, vec3[MAXIMUM_PALETTE_SIZE] resulting_colors) {
	for (int i = 0; i < old_colors.length(); i++){
		if (color * 255.0 == starting_colors[i]) {
			return resulting_colors[i]/255.0;
		}
	}
	return color;
}


void fragment() {
	COLOR.rgb = convert(COLOR.rgb, old_colors, new_colors);
	#ifdef GBA_COLOR
		COLOR.rgb = gba_color(COLOR.rgb);
	#endif
}
