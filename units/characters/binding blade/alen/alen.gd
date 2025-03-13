@tool
extends Unit


# Unit-specific variables.
func _enter_tree() -> void:
	_personal_values = {
		Stats.HIT_POINTS: 7,
		Stats.STRENGTH: 11,
		Stats.PIERCE: 5,
		Stats.INTELLIGENCE: 5,
		Stats.DEXTERITY: 5,
		Stats.SPEED: 6,
		Stats.LUCK: 9,
		Stats.DEFENSE: 6,
		Stats.ARMOR: 5,
		Stats.RESISTANCE: 5,
		Stats.MOVEMENT: 0,
		Stats.BUILD: 5,
	}
	super()
