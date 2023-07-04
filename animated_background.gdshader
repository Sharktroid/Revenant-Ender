shader_type canvas_item;

uniform float direction = 1.0;

void fragment() {
	float x_offset = (sin(UV.y*18.0 + TIME * 5.0) * 2.0)/70.0 * direction;
	COLOR.rgb = texture(TEXTURE, UV + vec2(x_offset, 0)).rgb;
}
