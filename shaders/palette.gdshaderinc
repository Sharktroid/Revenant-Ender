
#define MAX_PALETTE_SIZE 64
uniform vec4 old_colors[MAX_PALETTE_SIZE];
uniform vec4 new_colors[MAX_PALETTE_SIZE];


vec4 convert(vec4 color, vec4 tex_color) {
	vec3 modulate = max(color.rgb / tex_color.rgb, vec3(0));
	for (int i = 0; i < old_colors.length(); i++) {
		#define DIFFERENT_COLORS old_colors[i] != new_colors[i]
		if (DIFFERENT_COLORS && round(tex_color * 255.0) == round(old_colors[i] * 255.0)) {
			color = new_colors[i];
			break;
		}
	}
	color.rgb *= modulate.rgb;
	return color;
}
