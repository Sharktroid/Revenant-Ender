@tool
extends Unit


# Unit-specific variables.
func _enter_tree() -> void:
	_personal_hit_points = 6
	_personal_strength = 5
	_personal_pierce = 5
	_personal_intelligence = 5
	_personal_dexterity = 12
	_personal_speed = 10
	_personal_luck = 5
	_personal_defense = 8
	_personal_armor = 5
	_personal_resistance = 5
	_personal_movement = 0
	_personal_build = 5
	effort_dexterity = 50
	effort_speed = 50
	super()
