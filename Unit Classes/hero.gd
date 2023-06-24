extends FEUnit


func _init():
	_unit_class = "Champion"
	movement_type = movement_types.ADVANCED_FOOT
	_class_base_stats = {
		stats.HITPOINTS: 22,
		stats.STRENGTH: 6,
		stats.PIERCE: 0,
		stats.MAGIC: 0,
		stats.SKILL: 9,
		stats.SPEED: 10,
		stats.LUCK: 0,
		stats.DEFENSE: 8,
		stats.DURABILITY: 0,
		stats.RESISTANCE: 2,
		stats.MOVEMENT: 6,
		stats.CONSTITUTION: 10,
	}
