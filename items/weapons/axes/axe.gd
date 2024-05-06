class_name Axe
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	type = Types.AXE
	min_range = 1
	max_range = 1
	advantage_types = [Types.SPEAR]
	disadvantage_types = [Types.SWORD]
	super()
