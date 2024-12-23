@tool
class_name Champion
extends UnitClass


func _init() -> void:
	resource_name = "Champion"
	_max_level = 30
	_movement_type = MovementTypes.ADVANCED_FOOT
	_weight_modifier = 1
	_description = "An honorific bestowed upon famed mercenary masters."

	_base_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.B,
		Weapon.Types.AXE: Weapon.Ranks.C,
	}
	_max_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.S,
		Weapon.Types.AXE: Weapon.Ranks.A,
	}

	_base_hit_points = 51
	_base_strength = 29
	_base_pierce = 23
	_base_intelligence = 26
	_base_dexterity = 30
	_base_speed = 30
	_base_luck = 23
	_base_defense = 25
	_base_armor = 23
	_base_resistance = 24
	_base_movement = 7
	_base_build = 11

	super()
