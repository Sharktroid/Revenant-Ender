class_name Axe
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	type = types.AXE
	min_range = 1
	max_range = 1
	advantage_types = [types.SPEAR]
	disadvantage_types = [types.SWORD]
	super()

