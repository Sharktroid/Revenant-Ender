extends "res://Unit Classes/base_fe.gd"

# Unit-specific variables.
func _init():
	movement_type = "Advanced Foot"
	_unit_class = "Lord"
	weapon_levels[Weapon.types.SWORD] = 1
	strength = 5
	defense = 5
	base_movement = 5
	_max_health = 18
