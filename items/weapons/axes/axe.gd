class_name Axe
extends Weapon


# Weapon-specific variables.
func _init() -> void:
	_type = Types.AXE
	_min_range = 1
	_max_range = 1
	_advantage_types |= 1 << Types.SPEAR
	_disadvantage_types |= 1 << Types.SWORD
	_might += 12
	_hit += 80
	_weight += 12
	super()
