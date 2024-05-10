@tool
class_name Fighter
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	resource_name = "Fighter"
	_max_level = 20
	_movement_type = MovementTypes.FIGHTERS
	_description = "Axe-wielding soldiers whose attack offers little defense."

	_base_weapon_levels[Weapon.Types.AXE] = Weapon.Ranks.D
	_max_weapon_levels[Weapon.Types.AXE] = Weapon.Ranks.A

	_base_hit_points = 23
	_base_strength = 7
	_base_pierce = 0
	_base_intelligence = 0
	_base_skill = 6
	_base_speed = 6
	_base_luck = 2
	_base_defense = 4
	_base_armor = 2
	_base_resistance = 1
	_base_movement = 6
	_base_build = 11

	_end_hit_points = 47
	_end_strength = 24
	_end_pierce = 0
	_end_intelligence = 0
	_end_skill = 23
	_end_speed = 21
	_end_luck = 15
	_end_defense = 20
	_end_armor = 16
	_end_resistance = 17
	_end_movement = 6
	_end_build = 11
	super()
