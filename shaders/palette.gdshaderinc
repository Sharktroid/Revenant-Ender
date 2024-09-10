
#define MAX_PALETTE_SIZE 64
uniform vec4 old_colors[MAX_PALETTE_SIZE];
uniform vec4 new_colors[MAX_PALETTE_SIZE];
uniform vec4 modulate = vec4(1.0);


vec4 convert(vec4 color) {
	color /= modulate;
	for (int i = 0; i < old_colors.length(); i++) {
		#define DIFFERENT_COLORS old_colors[i] != new_colors[i]
		if (DIFFERENT_COLORS && round(color * 255.0) == round(old_colors[i] * 255.0)) {
			color = new_colors[i];
			break;
		}
	}
	color *= modulate;
	return color;
}
