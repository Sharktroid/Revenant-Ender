@tool
extends Unit


# Unit-specific variables.
func _init() -> void:
	weapon_levels[Weapon.Types.SWORD] = Weapon.Ranks.C
	_personal_hit_points = 5
	_personal_strength = 5
	_personal_pierce = 5
	_personal_intelligence = 5
	_personal_dexterity = 5
	_personal_speed = 8
	_personal_luck = 12
	_personal_defense = 5
	_personal_armor = 5
	_personal_resistance = 5
	_personal_movement = 5
	_personal_build = 5
	personal_authority = 1
