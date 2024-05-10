@tool
class_name Brigand
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	resource_name = "Brigand"
	_max_level = 20
	_movement_type = MovementTypes.BANDITS
	_description = "Mighty mountaineers who prefer axes in combat."

	_base_weapon_levels[Weapon.Types.AXE] = Weapon.Ranks.D
	_max_weapon_levels[Weapon.Types.AXE] = Weapon.Ranks.A

	_base_hit_points = 25
	_base_strength = 8
	_base_pierce = 0
	_base_intelligence = 0
	_base_skill = 2
	_base_speed = 5
	_base_luck = 0
	_base_defense = 4
	_base_armor = 1
	_base_resistance = 0
	_base_movement = 6
	_base_build = 12

	_end_hit_points = 50
	_end_strength = 25
	_end_pierce = 0
	_end_intelligence = 15
	_end_skill = 16
	_end_speed = 21
	_end_luck = 18
	_end_defense = 20
	_end_armor = 16
	_end_resistance = 15
	_end_movement = 6
	_end_build = 12
	super()
