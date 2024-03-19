shader_type canvas_item;

#include "res://palette.gdshaderinc"

void fragment() {
	COLOR.rgba = convert(COLOR.rgba);
}
