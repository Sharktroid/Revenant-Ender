@tool
extends Unit


# Unit-specific variables.
func _enter_tree() -> void:
	_personal_values = {
		Stats.HIT_POINTS: 5,
		Stats.STRENGTH: 5,
		Stats.PIERCE: 7,
		Stats.INTELLIGENCE: 5,
		Stats.DEXTERITY: 10,
		Stats.SPEED: 13,
		Stats.LUCK: 9,
		Stats.DEFENSE: 7,
		Stats.ARMOR: 5,
		Stats.RESISTANCE: 5,
		Stats.MOVEMENT: 0,
		Stats.BUILD: 5,
	}
	super()
