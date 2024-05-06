class_name Skill
extends Resource

enum AllVariants {ALPHA, BETA, GAMMA, OMEGA}
enum AllAttributes {
	FOLLOW_UP,
	CANTO,
}

var attributes: Array[AllAttributes]
var variants: Array[AllVariants]
var current_variant: AllVariants
