shader_type canvas_item;

#include "res://gba_color.gdshaderinc"
#include "res://palette.gdshaderinc"


void fragment() {
	COLOR.rgba = convert(COLOR.rgba);
	COLOR.rgb = gba_color(COLOR.rgb);
}
