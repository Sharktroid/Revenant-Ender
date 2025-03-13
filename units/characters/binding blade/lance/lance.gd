@tool
extends Unit


# Unit-specific variables.
func _enter_tree() -> void:
	_personal_values = {
		Stats.HIT_POINTS: 6,
		Stats.STRENGTH: 6,
		Stats.PIERCE: 5,
		Stats.INTELLIGENCE: 5,
		Stats.DEXTERITY: 12,
		Stats.SPEED: 11,
		Stats.LUCK: 5,
		Stats.DEFENSE: 8,
		Stats.ARMOR: 5,
		Stats.RESISTANCE: 5,
		Stats.MOVEMENT: 0,
		Stats.BUILD: 5,
	}
	super()
