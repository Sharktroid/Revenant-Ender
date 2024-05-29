@tool
class_name LordRoy
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	resource_name = "Lord"
	_description = "A noble attached to a ruling house. Has great potential."
	_max_level = 20
	_movement_type = MovementTypes.ADVANCED_FOOT

	_base_weapon_levels[Weapon.Types.SWORD] = Weapon.Ranks.C
	_max_weapon_levels[Weapon.Types.SWORD] = Weapon.Ranks.A

	_base_hit_points = 44
	_base_strength = 23
	_base_pierce = 0
	_base_intelligence = 0
	_base_skill = 23
	_base_speed = 24
	_base_luck = 25
	_base_defense = 25
	_base_armor = 25
	_base_resistance = 25
	_base_movement = 6
	_base_build = 6
	super()
