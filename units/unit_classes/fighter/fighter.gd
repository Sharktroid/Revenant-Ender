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

	_base_hit_points = 50
	_base_strength = 25
	_base_pierce = 20
	_base_intelligence = 22
	_base_dexterity = 22
	_base_speed = 24
	_base_luck = 20
	_base_defense = 22
	_base_armor = 20
	_base_resistance = 20
	_base_movement = 6
	_base_build = 11
	super()
