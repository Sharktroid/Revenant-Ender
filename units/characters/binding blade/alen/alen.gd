@tool
extends Unit


# Unit-specific variables.
func _init() -> void:
	personal_values = {
		Unit.Stats.HIT_POINTS: 7,
		Unit.Stats.STRENGTH: 12,
		Unit.Stats.PIERCE: 5,
		Unit.Stats.MAGIC: 5,
		Unit.Stats.SKILL: 5,
		Unit.Stats.SPEED: 7,
		Unit.Stats.LUCK: 10,
		Unit.Stats.DEFENSE: 6,
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

