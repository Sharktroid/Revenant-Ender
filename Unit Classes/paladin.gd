extends FEUnit


func _init():
	_unit_class = "Paladin"
	movement_type = movement_types.ADVANCED_HEAVY_CAVALRY
	_class_base_stats = {
		stats.HITPOINTS: 23,
		stats.STRENGTH: 7,
		stats.PIERCE: 0,
		stats.MAGIC: 0,
		stats.SKILL: 4,
		stats.SPEED: 7,
		stats.LUCK: 0,
		stats.DEFENSE: 8,
		stats.DURABILITY: 0,
		stats.RESISTANCE: 3,
		stats.MOVEMENT: 8,
		stats.CONSTITUTION: 11,
	}
