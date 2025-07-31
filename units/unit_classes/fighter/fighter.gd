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
	_base_strength = 21
	_base_pierce = 15
	_base_intelligence = 19
	_base_dexterity = 18
	_base_speed = 19
	_base_luck = 17
	_base_defense = 18
	_base_armor = 16
	_base_resistance = 15
	_base_movement = 6
	_base_build = 11
	super()
