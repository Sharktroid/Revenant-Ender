extends FEUnit


# Unit-specific variables.
func _init():
	_unit_class = "Archer"
	movement_type = movement_types.FOOT
	_class_base_stats = {
		stats.HITPOINTS: 18,
		stats.STRENGTH: 0,
		stats.PIERCE: 4,
		stats.MAGIC: 0,
		stats.SKILL: 3,
		stats.SPEED: 3,
		stats.LUCK: 0,
		stats.DEFENSE: 3,
		stats.DURABILITY: 0,
		stats.RESISTANCE: 0,
		stats.MOVEMENT: 5,
		stats.CONSTITUTION: 7,
	}
