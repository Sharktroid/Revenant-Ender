@tool
class_name Brigand
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	resource_name = "Brigand"
	_max_level = 20
	_movement_type = MovementTypes.BANDITS
	_description = "Mighty mountaineers who prefer axes in combat."

	_base_weapon_levels[Weapon.Types.AXE] = Weapon.Ranks.C
	_max_weapon_levels[Weapon.Types.AXE] = Weapon.Ranks.A

	_base_hit_points = 54
	_base_strength = 27
	_base_pierce = 0
	_base_intelligence = 20
	_base_dexterity = 20
	_base_speed = 26
	_base_luck = 22
	_base_defense = 23
	_base_armor = 21
	_base_resistance = 20
	_base_movement = 6
	_base_build = 12
	super()
