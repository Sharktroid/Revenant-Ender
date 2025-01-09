class_name Skill
extends Resource

enum Variants {ALPHA, BETA, GAMMA, OMEGA}

var current_variant: Variants
var _variants: Array[Variants]
var _name: String


func _to_string() -> String:
	return _name


func get_variants() -> Array[Variants]:
	return _variants
