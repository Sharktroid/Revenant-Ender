class_name Skill
extends Resource

enum Variants {ALPHA, BETA, GAMMA, OMEGA}

var current_variant: Variants
var _variants: Array[Variants]


func get_variants() -> Array[Variants]:
	return _variants
