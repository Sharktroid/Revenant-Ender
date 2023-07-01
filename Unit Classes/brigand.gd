extends FEUnit

# Unit-specific variables.
func _init():
	_unit_class = "Brigand"
	_max_level = 30
	movement_type = movement_types.BANDITS
	_class_base_stats = {
		stats.HITPOINTS: 18,
		stats.STRENGTH: 6,
		stats.PIERCE: 0,
		stats.MAGIC: 1,
		stats.SKILL: 2,
		stats.SPEED: 5,
		stats.LUCK: 0,
		stats.DEFENSE: 7,
		stats.DURABILITY: 2,
		stats.RESISTANCE: 1,
		stats.MOVEMENT: 5,
		stats.CONSTITUTION: 0,
		stats.LEADERSHIP: 0,
	}
	_class_end_stats = {
		stats.HITPOINTS: 34,
		stats.STRENGTH: 18,
		stats.PIERCE: 0,
		stats.MAGIC: 1,
		stats.SKILL: 9,
		stats.SPEED: 12,
		stats.LUCK: 3,
		stats.DEFENSE: 16,
		stats.DURABILITY: 9,
		stats.RESISTANCE: 7,
		stats.MOVEMENT: 5,
		stats.CONSTITUTION: 0,
		stats.LEADERSHIP: 0,
	}
	_class_stat_caps = {
		stats.HITPOINTS: 45,
		stats.STRENGTH: 24,
		stats.PIERCE: 0,
		stats.MAGIC: 19,
		stats.SKILL: 16,
		stats.SPEED: 20,
		stats.LUCK: 17,
		stats.DEFENSE: 23,
		stats.DURABILITY: 20,
		stats.RESISTANCE: 18,
		stats.MOVEMENT: 7,
		stats.CONSTITUTION: 0,
		stats.LEADERSHIP: 0,
	}
