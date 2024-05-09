class_name Spear
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	_type = Types.SPEAR
	_min_range = 1
	_max_range = 1
	_advantage_types = [Types.SWORD]
	_disadvantage_types = [Types.AXE]
	super()

