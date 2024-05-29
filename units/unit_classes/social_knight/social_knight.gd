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
		Weapon.Types.SWORD: Weapon.Ranks.D,
		Weapon.Types.SPEAR: Weapon.Ranks.C,
	}
	_max_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.B,
		Weapon.Types.SPEAR: Weapon.Ranks.A,
	}

	_base_hit_points = 40
	_base_strength = 25
	_base_pierce = 20
	_base_intelligence = 21
	_base_skill = 22
	_base_speed = 25
	_base_luck = 20
	_base_defense = 25
	_base_armor = 20
	_base_resistance = 25
	_base_movement = 8
	_base_build = 9
	super()
