extends FEUnit


# Unit-specific variables.
func _init():
	_unit_class = "Archer"
	_max_level = 30
	movement_type = movement_types.FOOT
	_class_base_stats = {
		stats.HITPOINTS: 17,
		stats.STRENGTH: 0,
		stats.PIERCE: 5,
		stats.MAGIC: 0,
		stats.SKILL: 7,
		stats.SPEED: 5,
		stats.LUCK: 2,
		stats.DEFENSE: 2,
		stats.DURABILITY: 5,
		stats.RESISTANCE: 4,
		stats.MOVEMENT: 5,
		stats.CONSTITUTION: 0,
		stats.LEADERSHIP: 0,
	}
	_class_end_stats = {
		stats.HITPOINTS: 38,
		stats.STRENGTH: 0,
		stats.PIERCE: 19,
		stats.MAGIC: 0,
		stats.SKILL: 22,
		stats.SPEED: 16,
		stats.LUCK: 10,
		stats.DEFENSE: 14,
		stats.DURABILITY: 21,
		stats.RESISTANCE: 18,
		stats.MOVEMENT: 5,
		stats.CONSTITUTION: 0,
		stats.LEADERSHIP: 0,
	}
	_class_stat_caps = {
		stats.HITPOINTS: 40,
		stats.STRENGTH: 15,
		stats.PIERCE: 20,
		stats.MAGIC: 15,
		stats.SKILL: 20,
		stats.SPEED: 19,
		stats.LUCK: 20,
		stats.DEFENSE: 20,
		stats.DURABILITY: 23,
		stats.RESISTANCE: 21,
		stats.MOVEMENT: 7,
		stats.CONSTITUTION: 0,
		stats.LEADERSHIP: 0,
	}
