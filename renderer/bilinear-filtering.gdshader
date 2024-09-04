shader_type canvas_item;

uniform int pixel_size = 1;

void fragment()
{
	ivec2 texture_size = textureSize(TEXTURE, 0) * pixel_size;
	#define TEXTURE_SIZE_FLOAT vec2(texture_size)

	vec2 pixel_position = UV * TEXTURE_SIZE_FLOAT - vec2(0.5);
	#define X pixel_position.x
	#define Y pixel_position.y

	#define COORD_1(COORD) int(floor(COORD))
	#define COORD_2(COORD) int(ceil(COORD))

	int x_1 = COORD_1(X);
	int x_2 = COORD_2(X);
	int y_1 = COORD_1(Y);
	int y_2 = COORD_2(Y);

	#define PIXEL_TO_UV(pixel, axis) (float(pixel) + 0.5) / TEXTURE_SIZE_FLOAT.axis
	#define TO_UV(x_val, y_val) vec2(PIXEL_TO_UV(x_val, x), PIXEL_TO_UV(y_val, y))
	#define COORD_TO_COLOR(x, y) texture(TEXTURE, TO_UV(x, y)).rgb

	#define X_1_Y_1_COLOR COORD_TO_COLOR(x_1, y_1)
	#define X_2_Y_1_COLOR COORD_TO_COLOR(x_2, y_1)
	#define X_1_Y_2_COLOR COORD_TO_COLOR(x_1, y_2)
	#define X_2_Y_2_COLOR COORD_TO_COLOR(x_2, y_2)

	#define Y_1_COLOR mix(X_1_Y_1_COLOR, X_2_Y_1_COLOR, X-float(x_1))
	#define Y_2_COLOR mix(X_1_Y_2_COLOR, X_2_Y_2_COLOR, X-float(x_1))

	COLOR.rgb = mix(Y_1_COLOR, Y_2_COLOR, Y - float(y_1));
}
