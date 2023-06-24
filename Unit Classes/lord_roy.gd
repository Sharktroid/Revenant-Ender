extends FEUnit


# Unit-specific variables.
func _init():
	_unit_class = "Lord"
	movement_type = movement_types.ADVANCED_FOOT
	weapon_levels[Weapon.types.SWORD] = 1
	_class_base_stats = {
		stats.HITPOINTS: 18,
		stats.STRENGTH: 3,
		stats.PIERCE: 0,
		stats.MAGIC: 0,
		stats.SKILL: 3,
		stats.SPEED: 4,
		stats.LUCK: 0,
		stats.DEFENSE: 5,
		stats.DURABILITY: 0,
		stats.RESISTANCE: 0,
		stats.MOVEMENT: 5,
		stats.CONSTITUTION: 6,
	}
