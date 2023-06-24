extends FEUnit

# Unit-specific variables.
func _init():
	_unit_class = "Brigand"
	movement_type = movement_types.BANDITS
	_class_base_stats = {
		stats.HITPOINTS: 20,
		stats.STRENGTH: 5,
		stats.PIERCE: 0,
		stats.MAGIC: 0,
		stats.SKILL: 1,
		stats.SPEED: 5,
		stats.LUCK: 0,
		stats.DEFENSE: 3,
		stats.DURABILITY: 0,
		stats.RESISTANCE: 0,
		stats.MOVEMENT: 5,
		stats.CONSTITUTION: 9,
	}
