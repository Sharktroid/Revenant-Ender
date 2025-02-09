shader_type canvas_item;

const float ALPHA_THRESHOLD = 0.0001;
uniform vec4 outlineColor = vec4(1.0);

#define SIZE ((1.0/TEXTURE_PIXEL_SIZE) + vec2(2.0))

void vertex() {
	VERTEX = mix(-vec2(1.0), VERTEX + vec2(1.0), VERTEX * TEXTURE_PIXEL_SIZE);
}

bool hasVisibleNeighbor(vec2 uv, vec2 size, sampler2D texture) {
	#define textureCheck(x, y) (texture(texture, vec2(x, y)).a > ALPHA_THRESHOLD)
	#define IN_BOUNDS(coordinate) (uv.coordinate >= 0.0 && uv.coordinate <= 1.0)

	//Theoretically these checks shouldn't do anything; leaving them here in case they are.
	//#define ABOVE_ZERO(coordinate) uv.coordinate > size.coordinate
	//#define BELOW_ONE(coordinate) uv.coordinate < 1.0 - size.coordinate

	if IN_BOUNDS(y) {
		#define TEX_CHECK_X(sgn) textureCheck(uv.x sgn size.x, uv.y)
		if (/*ABOVE_ZERO(x) && */TEX_CHECK_X(-)) {
			return true;
		}
		if (/*BELOW_ONE(x) && */TEX_CHECK_X(+)) {
			return true;
		}
	}
	if IN_BOUNDS(x) {
		#define TEX_CHECK_Y(sgn) textureCheck(uv.x, uv.y sgn size.y)
		if (/*ABOVE_ZERO(y) && */TEX_CHECK_Y(-)) {
			return true;
		}
		return /*BELOW_ONE(y) && */TEX_CHECK_Y(+);
	}
	return false;
}

void fragment() {
	vec2 new_uv = mix(-TEXTURE_PIXEL_SIZE, vec2(1.0) + TEXTURE_PIXEL_SIZE, UV);
	#define check(coordinate) (new_uv.coordinate >= 0.0 && new_uv.coordinate <= 1.0)
	COLOR = (check(x) && check(y)) ? texture(TEXTURE, new_uv) : vec4(0.0);
	if (COLOR.a < ALPHA_THRESHOLD && hasVisibleNeighbor(new_uv, TEXTURE_PIXEL_SIZE, TEXTURE)) {
		COLOR = outlineColor;
	}
}
