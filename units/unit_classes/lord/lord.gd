@tool
class_name Lord
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	resource_name = "Lord"
	_description = "A noble attached to a ruling house. Has great potential."
	_max_level = 20
	_movement_type = MovementTypes.ADVANCED_FOOT

	_weapon_levels[Weapon.Types.SWORD] = Weapon.Ranks.A

	_base_hit_points = 39
	_base_strength = 20
	_base_pierce = 15
	_base_intelligence = 18
	_base_dexterity = 19
	_base_speed = 20
	_base_luck = 19
	_base_defense = 17
	_base_armor = 18
	_base_resistance = 16
	_base_movement = 6
	_base_build = 8
	super()
