vec3 modify_saturation(vec3 color, float saturation_multiplier) {
	#define AVERAGE_COLOR (color.r + color.g + color.b)/3.0
	return mix(vec3(AVERAGE_COLOR), color, saturation_multiplier);
}