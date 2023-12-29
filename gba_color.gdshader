shader_type canvas_item;

#include "res://gba_color.gdshaderinc"

void fragment() {
	COLOR.rgb = gba_color(COLOR.rgb);
}