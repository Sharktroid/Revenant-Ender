class_name Sword
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	type = types.SWORD
	min_range = 1
	max_range = 1
	advantage_types = [types.AXE]
	disadvantage_types = [types.SPEAR]
	super()

