@tool
class_name Hero
extends UnitClass


func _init() -> void:
	resource_name = "Champion"
	_max_level = 30
	_movement_type = MovementTypes.ADVANCED_FOOT
	_weight_modifier = 1
	_description = "An honorific bestowed upon famed mercenary masters."

	_base_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.C,
		Weapon.Types.AXE: Weapon.Ranks.C,
	}
	_max_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.S,
		Weapon.Types.AXE: Weapon.Ranks.S,
	}

	_base_hit_points = 29
	_base_strength = 11
	_base_pierce = 0
	_base_intelligence = 5
	_base_skill = 13
	_base_speed = 12
	_base_luck = 6
	_base_defense = 5
	_base_armor = 3
	_base_resistance = 6
	_base_movement = 7
	_base_build = 11

	_end_hit_points = 50
	_end_strength = 28
	_end_pierce = 0
	_end_intelligence = 24
	_end_skill = 30
	_end_speed = 30
	_end_luck = 23
	_end_defense = 24
	_end_armor = 20
	_end_resistance = 26
	_end_movement = 7
	_end_build = 11

	_map_sprite = load("res://units/unit_classes/champion/champion_m.png")
