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

	_weapon_levels[Weapon.Types.SPEAR] = Weapon.Ranks.A

	_base_hit_points = 40
	_base_strength = 15
	_base_pierce = 12
	_base_intelligence = 12
	_base_dexterity = 12
	_base_speed = 10
	_base_luck = 16
	_base_defense = 17
	_base_armor = 14
	_base_resistance = 10
	_base_movement = 5
	_base_build = 13
	super()
