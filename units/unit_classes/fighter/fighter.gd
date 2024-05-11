@tool
class_name Fighter
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	resource_name = "Fighter"
	_max_level = 20
	_movement_type = MovementTypes.FIGHTERS
	_description = "Axe-wielding soldiers whose attack offers little defense."

	_base_weapon_levels[Weapon.Types.AXE] = Weapon.Ranks.C
	_max_weapon_levels[Weapon.Types.AXE] = Weapon.Ranks.A

	_base_hit_points = 29
	_base_strength = 7
	_base_pierce = 0
	_base_intelligence = 1
	_base_skill = 6
	_base_speed = 6
	_base_luck = 2
	_base_defense = 4
	_base_armor = 2
	_base_resistance = 0
	_base_movement = 6
	_base_build = 11

	_end_hit_points = 50
	_end_strength = 24
	_end_pierce = 20
	_end_intelligence = 22
	_end_skill = 23
	_end_speed = 24
	_end_luck = 20
	_end_defense = 24
	_end_armor = 20
	_end_resistance = 20
	_end_movement = 6
	_end_build = 11
	super()
