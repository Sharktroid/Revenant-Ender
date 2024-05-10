@tool
class_name Cavalier
extends MountedUnit


func _init() -> void:
	resource_name = "Cavalier"
	_max_level = 30
	_movement_type = MovementTypes.ADVANCED_HEAVY_CAVALRY
	_weight_modifier = 25
	_description = "Dedicated cavalry with superior abilities all around."

	_base_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.C,
		Weapon.Types.SPEAR: Weapon.Ranks.C,
		Weapon.Types.AXE: Weapon.Ranks.D,
	}

	_max_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.S,
		Weapon.Types.SPEAR: Weapon.Ranks.S,
		Weapon.Types.AXE: Weapon.Ranks.A,
	}

	_base_hit_points = 19
	_base_strength = 8
	_base_pierce = 0
	_base_intelligence = 1
	_base_skill = 7
	_base_speed = 7
	_base_luck = 4
	_base_defense = 7
	_base_armor = 6
	_base_resistance = 6
	_base_movement = 9
	_base_build = 11

	_end_hit_points = 51
	_end_strength = 28
	_end_pierce = 0
	_end_intelligence = 22
	_end_skill = 25
	_end_speed = 25
	_end_luck = 16
	_end_defense = 29
	_end_armor = 27
	_end_resistance = 26
	_end_movement = 9
	_end_build = 11
	super()
