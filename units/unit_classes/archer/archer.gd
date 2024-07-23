@tool
class_name Archer
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	resource_name = "Archer"
	_max_level = 20
	_movement_type = MovementTypes.FOOT
	_description = "Soldiers who attack from a distance with their bows."

	_base_weapon_levels[Weapon.Types.BOW] = Weapon.Ranks.C
	_max_weapon_levels[Weapon.Types.BOW] = Weapon.Ranks.A

	_base_hit_points = 44
	_base_strength = 20
	_base_pierce = 24
	_base_intelligence = 22
	_base_dexterity = 24
	_base_speed = 22
	_base_luck = 23
	_base_defense = 20
	_base_armor = 25
	_base_resistance = 25
	_base_movement = 6
	_base_build = 7
	super()
