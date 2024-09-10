vec3 modify_saturation(vec3 color, float saturation_multiplier) {
	#define AVERAGE_COLOR (color.r + color.g + color.b)/3.0
	return mix(vec3(AVERAGE_COLOR), color, saturation_multiplier);
}


// -1 for black; 1 for value * 2
vec3 modify_value(vec3 color, float value_multiplier) {
	#define MAX_COLOR max(max(color.r, color.g), color.b)
	if (value_multiplier > 0.0) {
		return mix(color, color * 2.0, value_multiplier);
	}
	else {
		return mix(color, vec3(0.0), abs(value_multiplier));
	}
}
