@tool
extends Unit


# Unit-specific variables.
func _init() -> void:
	personal_values = {
		Unit.stats.HIT_POINTS: 14,
		Unit.stats.STRENGTH: 10,
		Unit.stats.PIERCE: 5,
		Unit.stats.MAGIC: 5,
		Unit.stats.SKILL: 9,
		Unit.stats.SPEED: 7,
		Unit.stats.LUCK: 5,
		Unit.stats.DEFENSE: 7,
		Unit.stats.ARMOR: 5,
		Unit.stats.RESISTANCE: 5,
		Unit.stats.MOVEMENT: 5,
		Unit.stats.CONSTITUTION: 5,
	}
	effort_values = {
		Unit.stats.HIT_POINTS: 0,
		Unit.stats.STRENGTH: 0,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 0,
		Unit.stats.SPEED: 0,
		Unit.stats.LUCK: 0,
		Unit.stats.DEFENSE: 0,
		Unit.stats.ARMOR: 0,
		Unit.stats.RESISTANCE: 0,
		Unit.stats.MOVEMENT: 0,
		Unit.stats.CONSTITUTION: 0,
	}

