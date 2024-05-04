shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float visible_ratio = 1.0;

void fragment() {
	COLOR = textureLod(screen_texture, SCREEN_UV, 0.0);
	if (abs(UV.y - 0.5) * 2.0 > visible_ratio) {
		COLOR.a = 0.0;
	}
}