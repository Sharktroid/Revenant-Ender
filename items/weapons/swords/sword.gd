class_name Sword
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	_type = Types.SWORD
	_min_range = 1
	_max_range = 1
	_advantage_types = [Types.AXE]
	_disadvantage_types = [Types.SPEAR]
	super()
