extends Unit


func _init():
	_unit_class = "Paladin"
	_max_level = 50
	movement_type = movement_types.ADVANCED_HEAVY_CAVALRY
	_class_base_stats = {
		stats.HITPOINTS: 19,
		stats.STRENGTH: 8,
		stats.PIERCE: 0,
		stats.MAGIC: 1,
		stats.SKILL: 7,
		stats.SPEED: 7,
		stats.LUCK: 4,
		stats.DEFENSE: 7,
		stats.DURABILITY: 6,
		stats.RESISTANCE: 6,
		stats.MOVEMENT: 8,
		stats.CONSTITUTION: 0,
		stats.LEADERSHIP: 0,
	}
	_class_end_stats = {
		stats.HITPOINTS: 51,
		stats.STRENGTH: 28,
		stats.PIERCE: 0,
		stats.MAGIC: 1,
		stats.SKILL: 25,
		stats.SPEED: 25,
		stats.LUCK: 16,
		stats.DEFENSE: 29,
		stats.DURABILITY: 27,
		stats.RESISTANCE: 26,
		stats.MOVEMENT: 8,
		stats.CONSTITUTION: 0,
		stats.LEADERSHIP: 0,
	}
	_class_stat_caps = {
		stats.HITPOINTS: 60,
		stats.STRENGTH: 31,
		stats.PIERCE: 0,
		stats.MAGIC: 26,
		stats.SKILL: 30,
		stats.SPEED: 30,
		stats.LUCK: 32,
		stats.DEFENSE: 32,
		stats.DURABILITY: 32,
		stats.RESISTANCE: 32,
		stats.MOVEMENT: 10,
		stats.CONSTITUTION: 0,
		stats.LEADERSHIP: 0,
	}
