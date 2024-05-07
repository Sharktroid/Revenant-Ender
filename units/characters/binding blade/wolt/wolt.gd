@tool
extends Unit


# Unit-specific variables.
func _init() -> void:
	personal_values = {
		Unit.Stats.HIT_POINTS: 5,
		Unit.Stats.STRENGTH: 5,
		Unit.Stats.PIERCE: 7,
		Unit.Stats.MAGIC: 5,
		Unit.Stats.SKILL: 10,
		Unit.Stats.SPEED: 13,
		Unit.Stats.LUCK: 9,
		Unit.Stats.DEFENSE: 7,
		Unit.Stats.ARMOR: 5,
		Unit.Stats.RESISTANCE: 5,
		Unit.Stats.MOVEMENT: 5,
		Unit.Stats.CONSTITUTION: 5,
	}
	effort_values = {
		Unit.Stats.HIT_POINTS: 0,
		Unit.Stats.STRENGTH: 0,
		Unit.Stats.PIERCE: 0,
		Unit.Stats.MAGIC: 0,
		Unit.Stats.SKILL: 0,
		Unit.Stats.SPEED: 0,
		Unit.Stats.LUCK: 0,
		Unit.Stats.DEFENSE: 0,
		Unit.Stats.ARMOR: 0,
		Unit.Stats.RESISTANCE: 0,
		Unit.Stats.MOVEMENT: 0,
		Unit.Stats.CONSTITUTION: 0,
	}

