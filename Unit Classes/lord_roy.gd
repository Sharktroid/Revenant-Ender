extends FEUnit


# Unit-specific variables.
func _init():
	_unit_class = "Lord"
	movement_type = movement_types.ADVANCED_FOOT
	weapon_levels[Weapon.types.SWORD] = 1
	_class_base_stats = {
		stats.HITPOINTS: 18,
		stats.STRENGTH: 6,
		stats.PIERCE: 0,
		stats.MAGIC: 0,
		stats.SKILL: 5,
		stats.SPEED: 6,
		stats.LUCK: 0,
		stats.DEFENSE: 7,
		stats.DURABILITY: 0,
		stats.RESISTANCE: 0,
		stats.MOVEMENT: 5,
		stats.CONSTITUTION: 0,
		stats.LEADERSHIP: 0,
	}
	_class_end_stats = {
		stats.HITPOINTS: 39,
		stats.STRENGTH: 18,
		stats.PIERCE: 0,
		stats.MAGIC: 0,
		stats.SKILL: 14,
		stats.SPEED: 15,
		stats.LUCK: 12,
		stats.DEFENSE: 15,
		stats.DURABILITY: 0,
		stats.RESISTANCE: 6,
		stats.MOVEMENT: 5,
		stats.CONSTITUTION: 0,
		stats.LEADERSHIP: 0,
	}
	_class_stat_caps = {
		stats.HITPOINTS: 60,
		stats.STRENGTH: 27,
		stats.PIERCE: 0,
		stats.MAGIC: 20,
		stats.SKILL: 25,
		stats.SPEED: 26,
		stats.LUCK: 30,
		stats.DEFENSE: 26,
		stats.DURABILITY: 0,
		stats.RESISTANCE: 25,
		stats.MOVEMENT: 7,
		stats.CONSTITUTION: 0,
		stats.LEADERSHIP: 0,
	}
