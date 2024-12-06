shader_type canvas_item;

#include "res://shaders/palette.gdshaderinc"

uniform float white_percentage = 0.0;

void fragment() {
	COLOR = convert(COLOR, texture(TEXTURE, UV));
	COLOR.rgb = mix(COLOR.rgb, vec3(1.0), white_percentage);
}
