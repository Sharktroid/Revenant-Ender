shader_type canvas_item;

void fragment() {
	#define PIXELX UV.x / TEXTURE_PIXEL_SIZE.x
	COLOR.a = min(mod(round((PIXELX - 1.0)/2.0), 2), 1);
}
