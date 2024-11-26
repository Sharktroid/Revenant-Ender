shader_type canvas_item;

#include "res://shaders/gba_color.gdshaderinc"
#include "res://shaders/palette.gdshaderinc"

void fragment() {
	COLOR = convert(COLOR, COLOR);
	COLOR.rgb = gba_color(COLOR.rgb);
}
