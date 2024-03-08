class_name Spear
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	type = types.SPEAR
	min_range = 1
	max_range = 1
	advantage_types = [types.SWORD]
	disadvantage_types = [types.AXE]
	super()

