@tool
class_name Cavalier
extends MountedUnit


func _init() -> void:
	resource_name = "Cavalier"
	_max_level = 30
	_movement_type = MovementTypes.ADVANCED_HEAVY_CAVALRY
	_weight_modifier = 25
	_description = "Dedicated cavalry with superior abilities all around."

	_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.B,
		Weapon.Types.SPEAR: Weapon.Ranks.B,
	}

	_base_hit_points = 40
	_base_strength = 12
	_base_pierce = 10
	_base_intelligence = 10
	_base_dexterity = 13
	_base_speed = 12
	_base_luck = 10
	_base_defense = 12
	_base_armor = 8
	_base_resistance = 11
	_base_movement = 9
	_base_build = 11
	super()
