@tool
class_name Archer
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	resource_name = "Archer"
	_max_level = 20
	_movement_type = MovementTypes.FOOT
	_description = "Soldiers who attack from a distance with their bows."

	_base_weapon_levels[Weapon.Types.BOW] = Weapon.Ranks.D
	_max_weapon_levels[Weapon.Types.BOW] = Weapon.Ranks.A

	_base_hit_points = 23
	_base_strength = 0
	_base_pierce = 5
	_base_intelligence = 3
	_base_skill = 6
	_base_speed = 5
	_base_luck = 4
	_base_defense = 2
	_base_armor = 7
	_base_resistance = 6
	_base_movement = 6
	_base_build = 7

	_end_hit_points = 42
	_end_strength = 0
	_end_pierce = 21
	_end_intelligence = 17
	_end_skill = 24
	_end_speed = 19
	_end_luck = 23
	_end_defense = 16
	_end_armor = 25
	_end_resistance = 25
	_end_movement = 6
	_end_build = 7
	super()
