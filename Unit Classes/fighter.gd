extends "res://Unit Classes/base_fe.gd"


# Unit-specific variables.
func _init():
	movement_type = "Fighters"
	attack = 5
	defense = 2
	base_movement = 5
	_movement = 5

func _enter_tree() -> void:
	set_all_health(20)
	_unit_class = "Fighter"
