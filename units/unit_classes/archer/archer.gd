@tool
class_name Archer
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	resource_name = "Archer"
	_max_level = 20
	_movement_type = MovementTypes.FOOT
	_description = "Soldiers who attack from a distance with their bows."

	_weapon_levels[Weapon.Types.BOW] = Weapon.Ranks.B

	_base_hit_points = 37
	_base_strength = 15
	_base_pierce = 19
	_base_intelligence = 17
	_base_dexterity = 19
	_base_speed = 17
	_base_luck = 19
	_base_defense = 15
	_base_armor = 20
	_base_resistance = 20
	_base_movement = 6
	_base_build = 8
	super()
