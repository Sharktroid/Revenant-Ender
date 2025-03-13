@tool
extends Unit


# Unit-specific variables.
func _enter_tree() -> void:
	_personal_values = {
		Stats.HIT_POINTS: 12,
		Stats.STRENGTH: 9,
		Stats.PIERCE: 5,
		Stats.INTELLIGENCE: 5,
		Stats.DEXTERITY: 6,
		Stats.SPEED: 8,
		Stats.LUCK: 10,
		Stats.DEFENSE: 8,
		Stats.ARMOR: 5,
		Stats.RESISTANCE: 1,
		Stats.MOVEMENT: 0,
		Stats.BUILD: 5,
	}
	super()
