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
		Weapon.Types.SPEAR: Weapon.Ranks.B,
		Weapon.Types.AXE: Weapon.Ranks.C,
	}

	_max_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.A,
		Weapon.Types.SPEAR: Weapon.Ranks.S,
		Weapon.Types.AXE: Weapon.Ranks.A,
	}

	_base_hit_points = 50
	_base_strength = 27
	_base_pierce = 25
	_base_intelligence = 25
	_base_dexterity = 28
	_base_speed = 27
	_base_luck = 25
	_base_defense = 27
	_base_armor = 23
	_base_resistance = 26
	_base_movement = 9
	_base_build = 11
	super()
