class_name Skill
extends Resource

enum allVariants {ALPHA, BETA, GAMMA, OMEGA}
enum allAttributes {
	FOLLOW_UP,
	CANTO,
}

var attributes: Array[allAttributes]
var variants: Array[allVariants]
var current_variant: allVariants
