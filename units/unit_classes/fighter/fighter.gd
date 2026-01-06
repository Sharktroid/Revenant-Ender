@tool
class_name Fighter
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	resource_name = "Fighter"
	_max_level = 20
	_movement_type = MovementTypes.FIGHTERS
	_description = "Axe-wielding soldiers whose attack offers little defense."

	_weapon_levels[Weapon.Types.AXE] = Weapon.Ranks.B

	_base_hit_points = 52
	_base_strength = 11
	_base_pierce = 5
	_base_intelligence = 9
	_base_dexterity = 8
	_base_speed = 9
	_base_luck = 7
	_base_defense = 8
	_base_armor = 6
	_base_resistance = 5
	_base_movement = 6
	_base_build = 11
	super()
