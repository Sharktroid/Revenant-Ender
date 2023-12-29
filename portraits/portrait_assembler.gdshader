shader_type canvas_item;

void fragment() {
	if (COLOR.rgb == vec3(120, 160, 112)/255.0) {
		COLOR.a = 0.0;
	}
}