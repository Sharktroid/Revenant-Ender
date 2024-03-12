@tool
extends Unit


# Unit-specific variables.
func _init() -> void:
	personal_values = {
		Unit.stats.HITPOINTS: 5,
		Unit.stats.STRENGTH: 5,
		Unit.stats.PIERCE: 7,
		Unit.stats.MAGIC: 5,
		Unit.stats.SKILL: 10,
		Unit.stats.SPEED: 13,
		Unit.stats.LUCK: 9,
		Unit.stats.DEFENSE: 7,
		Unit.stats.ARMOR: 5,
		Unit.stats.RESISTANCE: 5,
		Unit.stats.MOVEMENT: 5,
		Unit.stats.CONSTITUTION: 5,
	}
	effort_values = {
		Unit.stats.HITPOINTS: 0,
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

