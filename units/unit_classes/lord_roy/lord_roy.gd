@tool
class_name LordRoy
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	resource_name = "Lord"
	_description = "A noble attached to a ruling house. Has great potential."
	_max_level = 20
	_movement_type = MovementTypes.ADVANCED_FOOT

	_base_weapon_levels[Weapon.Types.SWORD] = Weapon.Ranks.D
	_max_weapon_levels[Weapon.Types.SWORD] = Weapon.Ranks.A

	_base_hit_points = 23
	_base_strength = 6
	_base_pierce = 0
	_base_magic = 0
	_base_skill = 5
	_base_speed = 6
	_base_luck = 0
	_base_defense = 7
	_base_armor = 0
	_base_resistance = 0
	_base_movement = 6
	_base_constitution = 6

	_end_hit_points = 44
	_end_strength = 23
	_end_pierce = 0
	_end_magic = 0
	_end_skill = 23
	_end_speed = 24
	_end_luck = 25
	_end_defense = 21
	_end_armor = 19
	_end_resistance = 18
	_end_movement = 6
	_end_constitution = 6
	super()
