shader_type canvas_item;

uniform vec2 center;
uniform float zoom = 1.0;

void vertex() {
	VERTEX -= center;
	VERTEX *= zoom;
	VERTEX += center;
}
