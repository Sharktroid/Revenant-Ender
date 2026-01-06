@tool
class_name Brigand
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	resource_name = "Brigand"
	_max_level = 20
	_movement_type = MovementTypes.BANDITS
	_description = "Mighty mountaineers who prefer axes in combat."

	_weapon_levels[Weapon.Types.AXE] = Weapon.Ranks.B

	_base_hit_points = 44
	_base_strength = 12
	_base_pierce = 5
	_base_intelligence = 5
	_base_dexterity = 5
	_base_speed = 11
	_base_luck = 7
	_base_defense = 8
	_base_armor = 6
	_base_resistance = 5
	_base_movement = 6
	_base_build = 12
	super()
