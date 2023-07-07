shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float amplitude = 10;
uniform float y_frequency = 1;
uniform float time_frequency = 1;
uniform bool split = false;

void fragment() {
	float y_factor = (SCREEN_UV.y * 160.0 / PI * y_frequency);
	float time_factor = (TIME * 16.0 / PI * time_frequency);
	float x_offset = sin(y_factor + time_factor)/512.0 * amplitude;
	if (mod(SCREEN_UV.y * 288.0, 2.0) > 1.0 && split){
		x_offset *= -1.0;
	}
	COLOR.rgba = texture(screen_texture, SCREEN_UV + vec2(x_offset, 0)).rgba;
}
