@tool
class_name SocialKnight
extends MountedUnit


# Unit-specific variables.
func _init() -> void:
	resource_name = "Social Knight"
	_max_level = 20
	_movement_type = MovementTypes.HEAVY_CAVALRY
	_weight_modifier = 25
	_description = "Mounted knights with superior movement."

	_base_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.E,
		Weapon.Types.SPEAR: Weapon.Ranks.D,
	}
	_max_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.B,
		Weapon.Types.SPEAR: Weapon.Ranks.A,
	}

	_base_hit_points = 17
	_base_strength = 6
	_base_pierce = 0
	_base_intelligence = 0
	_base_skill = 5
	_base_speed = 5
	_base_luck = 3
	_base_defense = 5
	_base_armor = 4
	_base_resistance = 3
	_base_movement = 8
	_base_build = 9

	_end_hit_points = 42
	_end_strength = 21
	_end_pierce = 0
	_end_intelligence = 0
	_end_skill = 21
	_end_speed = 19
	_end_luck = 15
	_end_defense = 21
	_end_armor = 19
	_end_resistance = 18
	_end_movement = 8
	_end_build = 9
	super()
