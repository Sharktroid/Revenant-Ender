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
	_base_strength = 25
	_base_pierce = 22
	_base_intelligence = 22
	_base_dexterity = 22
	_base_speed = 20
	_base_luck = 26
	_base_defense = 27
	_base_armor = 24
	_base_resistance = 20
	_base_movement = 5
	_base_build = 13
	super()
