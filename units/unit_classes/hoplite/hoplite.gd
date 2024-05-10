@tool
class_name Hoplite
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	resource_name = "Hoplite"
	_max_level = 20
	_movement_type = MovementTypes.ARMOR
	_weight_modifier = 5
	_description = "Heavily armored knights with stout defense, but low speed."

	_base_weapon_levels[Weapon.Types.SPEAR] = Weapon.Ranks.D
	_max_weapon_levels[Weapon.Types.SPEAR] = Weapon.Ranks.A

	_base_hit_points = 19
	_base_strength = 8
	_base_pierce = 0
	_base_intelligence = 0
	_base_skill = 5
	_base_speed = 3
	_base_luck = 3
	_base_defense = 8
	_base_armor = 5
	_base_resistance = 1
	_base_movement = 6
	_base_build = 13

	_end_hit_points = 50
	_end_strength = 22
	_end_pierce = 0
	_end_intelligence = 0
	_end_skill = 21
	_end_speed = 15
	_end_luck = 24
	_end_defense = 25
	_end_armor = 24
	_end_resistance = 17
	_end_movement = 6
	_end_build = 13
	super()

