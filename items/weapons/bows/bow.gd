class_name Bow
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	type = types.BOW
	min_range = 2
	max_range = 2
	super()

