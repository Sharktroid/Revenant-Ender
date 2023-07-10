shader_type canvas_item;

/*
This can be used to keep pixels well defined at higher resolutions. Integer
values will work best. Should only be greater than or equal to 1.
*/
uniform float pixel_scale = 1.0;

// Based on https://en.wikipedia.org/wiki/Bilinear_filtering
void fragment()
{
	#define texSize vec2(vec2(textureSize(TEXTURE, 0)) * pixel_scale)
	#define texturePosition vec2(UV * texSize - vec2(0.5))
	#define x1 floor(texturePosition.x)
	#define xFrac float(texturePosition.x - x1)
	#define y1 floor(texturePosition.y)
	#define yFrac float(texturePosition.y - y1)
	#define x2 x1 + 1.0
	#define y2 y1 + 1.0

	#define x1Uv float(x1 + 0.5)/texSize.x
	#define y1Uv float(y1 + 0.5)/texSize.y
	#define x2Uv float(x2 + 0.5)/texSize.x
	#define y2Uv float(y2 + 0.5)/texSize.y

	#define z11 texture(TEXTURE, vec2(x1Uv, y1Uv)).rgb
	#define z12 texture(TEXTURE, vec2(x1Uv, y2Uv)).rgb
	#define z21 texture(TEXTURE, vec2(x2Uv, y1Uv)).rgb
	#define z22 texture(TEXTURE, vec2(x2Uv, y2Uv)).rgb

	#define f1Result vec3(z11 + yFrac * (z12 - z11))
	#define f2Result vec3(z21 + yFrac * (z22 - z21))

	COLOR.rgb = f1Result + xFrac * (f2Result - f1Result);
}
