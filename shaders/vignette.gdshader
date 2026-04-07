shader_type canvas_item;

#define ROUND 64.0

#define MAX_ALPHA (2.0/5.0)

void fragment() {
	COLOR.a = round(((pow(UV.x - 0.5, 2) + pow(UV.y - 0.5, 2))/0.5*MAX_ALPHA)*ROUND)/ROUND;
}