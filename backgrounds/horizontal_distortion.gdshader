shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

const int SCREEN_WIDTH = 512;

uniform float amplitude = 16;
uniform float y_frequency = 1; // 1 means exactly one wave; top and bottom have same
uniform float time_frequency = 1; // 1 means one wave per second
uniform bool split = false;
uniform bool wrap_around = true;

void fragment() {
	#define Y_FACTOR SCREEN_UV.y * TAU * y_frequency
	#define TIME_FACTOR TIME * TAU * time_frequency
	#define X_OFFSET sin(Y_FACTOR + TIME_FACTOR)/(2.0 * float(SCREEN_WIDTH)) * amplitude * reverse
	float reverse = 1.0;
	if (mod(SCREEN_UV.y * 288.0, 2.0) > 1.0 && split){
		reverse *= -1.0;
	}

	#define OFFSET_UV SCREEN_UV + vec2(X_OFFSET, 0)
	#define FORMAT_COLOR(FORMATTED_UV) COLOR = texture(screen_texture, FORMATTED_UV)
	if (wrap_around){
		FORMAT_COLOR(mod(OFFSET_UV, 1));
	}
	else {
		FORMAT_COLOR(OFFSET_UV);
	}
}
