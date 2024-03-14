class_name Skill
extends Resource

enum all_variants {ALPHA, BETA, GAMMA, OMEGA}
enum all_attributes {
	FOLLOW_UP,
	CANTO,
}

var attributes: Array[all_attributes]
var variants: Array[all_variants]
var current_variant: all_variants
