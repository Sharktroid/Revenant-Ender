extends Unit


# Unit-specific variables.
func _init():
	_unit_class = "Hoplite"
	_max_level = 30
	movement_type = movement_types.ARMOR
	_class_base_stats = {
		stats.HITPOINTS: 19,
		stats.STRENGTH: 8,
		stats.PIERCE: 0,
		stats.MAGIC: 0,
		stats.SKILL: 5,
		stats.SPEED: 3,
		stats.LUCK: 3,
		stats.DEFENSE: 8,
		stats.DURABILITY: 5,
		stats.RESISTANCE: 1,
		stats.MOVEMENT: 4,
		stats.CONSTITUTION: 13,
		stats.LEADERSHIP: 0
	}
	_class_end_stats = {
		stats.HITPOINTS: 43,
		stats.STRENGTH: 25,
		stats.PIERCE: 0,
		stats.MAGIC: 0,
		stats.SKILL: 19,
		stats.SPEED: 11,
		stats.LUCK: 12.0,
		stats.DEFENSE: 23,
		stats.DURABILITY: 20,
		stats.RESISTANCE: 10,
		stats.MOVEMENT: 4,
		stats.CONSTITUTION: 13,
		stats.LEADERSHIP: 0
	}
	_class_stat_caps = {
		stats.HITPOINTS: 60,
		stats.STRENGTH: 20,
		stats.PIERCE: 20,
		stats.MAGIC: 20,
		stats.SKILL: 20,
		stats.SPEED: 17,
		stats.LUCK: 22,
		stats.DEFENSE: 26,
		stats.DURABILITY: 24,
		stats.RESISTANCE: 18,
		stats.MOVEMENT: 15,
		stats.CONSTITUTION: 20,
		stats.LEADERSHIP: 5
	}

