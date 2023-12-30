shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float gradient_speed = 1.0;
uniform bool use_screen_texture = false;

void fragment() {
	vec4 grabbed_color = COLOR;
	if (use_screen_texture) {
		grabbed_color = texture(screen_texture, SCREEN_UV);
	}

	COLOR.rgb = vec3(1.0, (abs(mod((grabbed_color.g + TIME) * gradient_speed, 2.0) - 1.0)), 0.0);
	COLOR.a = grabbed_color.a;
}
