shader_type canvas_item;

void fragment() {
	COLOR = texture(TEXTURE, vec2(mod(UV.x + TIME/20.0, 1.0), UV.y));
}
