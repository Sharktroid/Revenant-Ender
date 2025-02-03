@tool
class_name Knight
extends MountedUnit


# Unit-specific variables.
func _init() -> void:
	resource_name = "Knight"
	_max_level = 20
	_movement_type = MovementTypes.HEAVY_CAVALRY
	_weight_modifier = 25
	_description = "Mounted knights with superior movement."

	_base_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.D,
		Weapon.Types.SPEAR: Weapon.Ranks.C,
	}
	_max_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.B,
		Weapon.Types.SPEAR: Weapon.Ranks.A,
	}

	_base_hit_points = 44
	_base_strength = 19
	_base_pierce = 18
	_base_intelligence = 17
	_base_dexterity = 17
	_base_speed = 20
	_base_luck = 17
	_base_defense = 18
	_base_armor = 17
	_base_resistance = 18
	_base_movement = 8
	_base_build = 8
	super()
