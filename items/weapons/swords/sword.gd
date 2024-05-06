class_name Sword
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	type = Types.SWORD
	min_range = 1
	max_range = 1
	advantage_types = [Types.AXE]
	disadvantage_types = [Types.SPEAR]
	super()

