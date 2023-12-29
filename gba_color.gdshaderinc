
/*
   Shader Modified: Pokefan531
   Converted to Godot by Sharktroid
   Color Mangler
   Author: hunterk
   License: Public domain
*/

// Shader that replicates the LCD dynamics from a GameBoy Advance
uniform float darken_screen = 0.5;

#define TARGET_GAMMA 2.2
#define DISPLAY_GAMMA 2.2
#define SAT 1.0
#define LUMINOSITY 1.0
#define CONTRAST 1.0
#define R 0.845
#define G 0.68
#define B 0.755
#define RG 0.09
#define RB 0.16
#define GR 0.17
#define GB 0.085
#define BR -0.015
#define BG 0.23

#define saturate(input) clamp(input, 0.0, 1.0)

vec3 gba_color(vec3 input_color) {
	#define AVGLUM vec3(0.5)
	#define SCREEN mix(pow(input_color, vec3(TARGET_GAMMA + darken_screen)), AVGLUM, (1.0 - CONTRAST))

	#define C mat3(vec3(R,	RG,	 RB), vec3(GR,	G,	 GB), vec3(BR,	BG,	 B))
	#define RED_ADJUST vec3((1.0 - SAT) * 0.3086 + SAT,(1.0 - SAT) * 0.3086 ,(1.0 - SAT) * 0.3086)
	#define GREEN_ADJUST vec3((1.0 - SAT) * 0.6094, (1.0 - SAT) * 0.6094 + SAT,(1.0 - SAT) * 0.6094)
	#define BLUE_ADJUST vec3((1.0 - SAT) * 0.0820, (1.0 - SAT) * 0.0820, (1.0 - SAT) * 0.0820 + SAT)
	#define ADJUST mat3(RED_ADJUST, GREEN_ADJUST, BLUE_ADJUST)

	return pow((C * ADJUST) * saturate(SCREEN * LUMINOSITY), vec3(1.0 / DISPLAY_GAMMA));
}
