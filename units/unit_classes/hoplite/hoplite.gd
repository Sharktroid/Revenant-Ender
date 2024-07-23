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

	_base_weapon_levels[Weapon.Types.SPEAR] = Weapon.Ranks.B
	_max_weapon_levels[Weapon.Types.SPEAR] = Weapon.Ranks.S

	_base_hit_points = 50
	_base_strength = 22
	_base_pierce = 0
	_base_intelligence = 0
	_base_dexterity = 21
	_base_speed = 15
	_base_luck = 24
	_base_defense = 25
	_base_armor = 24
	_base_resistance = 17
	_base_movement = 6
	_base_build = 13
	super()

