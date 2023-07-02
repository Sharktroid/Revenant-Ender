extends Unit


# Unit-specific variables.
func _init():
	_unit_class = "Fighter"
	_max_level = 30
	movement_type = movement_types.FIGHTERS
	_class_base_stats = {
		stats.HITPOINTS: 19,
		stats.STRENGTH: 7,
		stats.PIERCE: 0,
		stats.MAGIC: 0,
		stats.SKILL: 6,
		stats.SPEED: 6,
		stats.LUCK: 2,
		stats.DEFENSE: 4,
		stats.DURABILITY: 2,
		stats.RESISTANCE: 1,
		stats.MOVEMENT: 5,
		stats.CONSTITUTION: 0,
		stats.LEADERSHIP: 0,
	}
	_class_end_stats = {
		stats.HITPOINTS: 43,
		stats.STRENGTH: 25,
		stats.PIERCE: 0,
		stats.MAGIC: 0,
		stats.SKILL: 23,
		stats.SPEED: 20,
		stats.LUCK: 7,
		stats.DEFENSE: 16,
		stats.DURABILITY: 12,
		stats.RESISTANCE: 10,
		stats.MOVEMENT: 5,
		stats.CONSTITUTION: 0,
		stats.LEADERSHIP: 0,
	}
	_class_stat_caps = {
		stats.HITPOINTS: 45,
		stats.STRENGTH: 25,
		stats.PIERCE: 0,
		stats.MAGIC: 15,
		stats.SKILL: 23,
		stats.SPEED: 22,
		stats.LUCK: 21,
		stats.DEFENSE: 19,
		stats.DURABILITY: 18,
		stats.RESISTANCE: 18,
		stats.MOVEMENT: 7,
		stats.CONSTITUTION: 0,
		stats.LEADERSHIP: 0,
	}
