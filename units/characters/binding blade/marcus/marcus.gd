@tool
extends Unit


# Unit-specific variables.
func _init() -> void:
	weapon_levels[Weapon.Types.SPEAR] = Weapon.Ranks.S
	_personal_hit_points = 0
	_personal_strength = 0
	_personal_pierce = 0
	_personal_intelligence = 0
	_personal_dexterity = 0
	_personal_speed = 0
	_personal_luck = 0
	_personal_defense = 0
	_personal_armor = 0
	_personal_resistance = 0
	_personal_movement = 0
	_personal_build = 0

	effort_hit_points = 100
	effort_strength = 50
	effort_pierce = 0
	effort_intelligence = 0
	effort_dexterity = 250
	effort_speed = 150
	effort_luck = 200
	effort_defense = 50
	effort_armor = 50
	effort_resistance = 150
	effort_movement = 0
	effort_build = 0
	personal_authority = 1

