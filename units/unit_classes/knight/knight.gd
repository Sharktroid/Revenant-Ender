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

	_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.D,
		Weapon.Types.SPEAR: Weapon.Ranks.C,
	}

	_base_hit_points = 44
	_base_strength = 9
	_base_pierce = 8
	_base_intelligence = 7
	_base_dexterity = 7
	_base_speed = 10
	_base_luck = 7
	_base_defense = 8
	_base_armor = 7
	_base_resistance = 8
	_base_movement = 8
	_base_build = 8
	super()
