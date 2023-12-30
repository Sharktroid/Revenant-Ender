shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform vec2 start = vec2(0);
uniform vec2 end = vec2(1);
uniform vec2 scroll = vec2(0);
uniform vec2 starting_offset = vec2(0);

void fragment() {
	#define ADJUSTED_UV SCREEN_UV + scroll * TIME + starting_offset
	COLOR = texture(screen_texture, mod(ADJUSTED_UV, end - start) + start);
}
