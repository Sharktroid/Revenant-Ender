class_name Spear
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	type = Types.SPEAR
	min_range = 1
	max_range = 1
	advantage_types = [Types.SWORD]
	disadvantage_types = [Types.AXE]
	super()

