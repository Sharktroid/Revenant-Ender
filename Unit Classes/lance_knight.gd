extends FEUnit


# Unit-specific variables.
func _init():
	_unit_class = "Hoplite"
	movement_type = movement_types.ARMOR
	_class_base_stats = {
		stats.HITPOINTS: 17,
		stats.STRENGTH: 5,
		stats.PIERCE: 0,
		stats.MAGIC: 0,
		stats.SKILL: 2,
		stats.SPEED: 0,
		stats.LUCK: 0,
		stats.DEFENSE: 9,
		stats.DURABILITY: 0,
		stats.RESISTANCE: 0,
		stats.MOVEMENT: 4,
		stats.CONSTITUTION: 13,
	}

