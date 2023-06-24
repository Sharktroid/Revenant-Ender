extends "res://Unit Classes/base_fe.gd"

# Unit-specific variables.
func _init():
	_unit_class = "Lord"
	movement_type = movement_types.ADVANCED_FOOT
	weapon_levels[Weapon.types.SWORD] = 1
	strength = 5
	defense = 5
	base_movement = 5
	_max_health = 18
