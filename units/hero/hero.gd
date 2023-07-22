extends Unit


func _init():
	_unit_class = "Champion"
	_max_level = 50
	movement_type = movement_types.ADVANCED_FOOT
	_class_base_stats = {
		stats.HITPOINTS: 20,
		stats.STRENGTH: 8,
		stats.PIERCE: 0,
		stats.MAGIC: 0,
		stats.SKILL: 10,
		stats.SPEED: 8,
		stats.LUCK: 3,
		stats.DEFENSE: 3,
		stats.DURABILITY: 5,
		stats.RESISTANCE: 5,
		stats.MOVEMENT: 6,
		stats.CONSTITUTION: 0,
		stats.LEADERSHIP: 0,
	}
	_class_end_stats = {
		stats.HITPOINTS: 56,
		stats.STRENGTH: 28,
		stats.PIERCE: 0,
		stats.MAGIC: 0,
		stats.SKILL: 35,
		stats.SPEED: 30,
		stats.LUCK: 15,
		stats.DEFENSE: 20,
		stats.DURABILITY: 26,
		stats.RESISTANCE: 25,
		stats.MOVEMENT: 6,
		stats.CONSTITUTION: 0,
		stats.LEADERSHIP: 0,
	}
	_class_stat_caps = {
		stats.HITPOINTS: 60,
		stats.STRENGTH: 32,
		stats.PIERCE: 0,
		stats.MAGIC: 25,
		stats.SKILL: 35,
		stats.SPEED: 32,
		stats.LUCK: 31,
		stats.DEFENSE: 27,
		stats.DURABILITY: 30,
		stats.RESISTANCE: 30,
		stats.MOVEMENT: 8,
		stats.CONSTITUTION: 0,
		stats.LEADERSHIP: 0,
	}
