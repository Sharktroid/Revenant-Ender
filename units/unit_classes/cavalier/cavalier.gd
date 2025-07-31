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
	_base_strength = 22
	_base_pierce = 20
	_base_intelligence = 20
	_base_dexterity = 23
	_base_speed = 22
	_base_luck = 20
	_base_defense = 22
	_base_armor = 18
	_base_resistance = 21
	_base_movement = 9
	_base_build = 11
	super()
