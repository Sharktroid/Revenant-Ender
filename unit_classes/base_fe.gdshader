shader_type canvas_item;

uniform vec3 old_colors[64];
uniform vec3 new_colors[64];

// Start of GBA shader code
uniform float darken_screen = 0.500;
const float target_gamma = 2.2;
const float display_gamma = 2.5;
const float sat = 1.0;
const float lum = 0.99;
const float contrast = 1.0;
const vec3 bl =	vec3(0.0,	0.0,	0.0);
const vec3 r =	vec3(0.84,	0.09,	0.15);
const vec3 g =	vec3(0.18,	0.67,	0.10);
const vec3 b =	vec3(0.0,	0.26,	0.73);


void GBA_color(inout vec4 color) {
	vec4 screen = pow(color, vec4(target_gamma + darken_screen)).rgba;
	vec4 avglum = vec4(0.5);
	screen = mix(screen, avglum, (1.0 - contrast));
 
	mat4 modified_color = mat4(	vec4(r.r,	r.g,	r.b,	0.0),
						vec4(g.r,	g.g,	g.b,	0.0),
						vec4(b.r,	b.g,	b.b,	0.0),
						vec4(bl.r,	bl.g,	bl.b,	1.0));
	mat4 adjust = mat4(vec4((1.0 - sat) * 0.3086 + sat,	(1.0 - sat) * 0.3086,		(1.0 - sat) * 0.3086,		1.0),
				vec4((1.0 - sat) * 0.6094,		(1.0 - sat) * 0.6094 + sat,	(1.0 - sat) * 0.6094,		1.0),
				vec4((1.0 - sat) * 0.0820,		(1.0 - sat) * 0.0820,		(1.0 - sat) * 0.0820 + sat,	1.0),
				vec4(0.0,				0.0,				0.0,				1.0));
	color *= adjust;
	screen = clamp(screen * lum, 0.0, 1.0);
	screen = modified_color * screen;
	color = pow(screen, vec4(1.0 / display_gamma + (darken_screen * 0.125)));
	
	}
// End of GBA shader code

void convert(inout vec4 color, vec3 starting_colors, vec3 resulting_colors) {
	if (color.rgb * 255.0 == starting_colors.rgb) {
		color.rgb = resulting_colors/255.0;
	}
}


void fragment() {
	
	for (int i = 0; i < old_colors.length(); i++){
		convert(COLOR, old_colors[i], new_colors[i]);
	}
	GBA_color(COLOR);
//	COLOR.rgb = old_colors[0];
}
