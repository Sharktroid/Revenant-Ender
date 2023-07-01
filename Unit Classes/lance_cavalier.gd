extends FEUnit


# Unit-specific variables.
func _init():
	_unit_class = "Social Knight"
	_max_level = 30
	movement_type = movement_types.HEAVY_CAVALRY
	_class_base_stats = {
		stats.HITPOINTS: 17,
		stats.STRENGTH: 6,
		stats.PIERCE: 0,
		stats.MAGIC: 0,
		stats.SKILL: 5,
		stats.SPEED: 5,
		stats.LUCK: 3,
		stats.DEFENSE: 5,
		stats.DURABILITY: 4,
		stats.RESISTANCE: 3,
		stats.MOVEMENT: 7,
		stats.CONSTITUTION: 9,
		stats.LEADERSHIP: 0,
	}
	_class_end_stats = {
		stats.HITPOINTS: 38,
		stats.STRENGTH: 21,
		stats.PIERCE: 0,
		stats.MAGIC: 0,
		stats.SKILL: 19,
		stats.SPEED: 17,
		stats.LUCK: 12,
		stats.DEFENSE: 20,
		stats.DURABILITY: 18,
		stats.RESISTANCE: 17,
		stats.MOVEMENT: 7,
		stats.CONSTITUTION: 9,
		stats.LEADERSHIP: 0,
	}
	_class_stat_caps = {
		stats.HITPOINTS: 40,
		stats.STRENGTH: 22,
		stats.PIERCE: 0,
		stats.MAGIC: 15,
		stats.SKILL: 21,
		stats.SPEED: 20,
		stats.LUCK: 24,
		stats.DEFENSE: 22,
		stats.DURABILITY: 21,
		stats.RESISTANCE: 21,
		stats.MOVEMENT: 9,
		stats.CONSTITUTION: 20,
		stats.LEADERSHIP: 0,
	}
