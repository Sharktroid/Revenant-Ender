extends FEUnit


# Unit-specific variables.
func _init():
	_unit_class = "Social Knight"
	movement_type = movement_types.HEAVY_CAVALRY
	_class_base_stats = {
		stats.HITPOINTS: 20,
		stats.STRENGTH: 5,
		stats.PIERCE: 0,
		stats.MAGIC: 0,
		stats.SKILL: 2,
		stats.SPEED: 5,
		stats.LUCK: 0,
		stats.DEFENSE: 6,
		stats.DURABILITY: 0,
		stats.RESISTANCE: 0,
		stats.MOVEMENT: 7,
		stats.CONSTITUTION: 9,
	}
