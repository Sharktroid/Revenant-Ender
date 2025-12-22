@tool
extends Unit


# Unit-specific variables.
func _enter_tree() -> void:
	_personal_values = {
		Stats.HIT_POINTS: 5,
		Stats.STRENGTH: 5,
		Stats.PIERCE: 5,
		Stats.INTELLIGENCE: 5,
		Stats.DEXTERITY: 5,
		Stats.SPEED: 8,
		Stats.LUCK: 12,
		Stats.DEFENSE: 5,
		Stats.ARMOR: 5,
		Stats.RESISTANCE: 5,
		Stats.MOVEMENT: 0,
		Stats.BUILD: 5,
	}
	personal_authority = 1
	_personal_skills.append(Lunge.new())
	super()
