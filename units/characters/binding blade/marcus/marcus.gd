@tool
extends Unit


# Unit-specific variables.
func _enter_tree() -> void:
	set_weapon_level(Weapon.Types.SPEAR, Weapon.Ranks.S)
	_personal_values = {
		Stats.HIT_POINTS: 0,
		Stats.STRENGTH: 0,
		Stats.PIERCE: 0,
		Stats.INTELLIGENCE: 0,
		Stats.DEXTERITY: 0,
		Stats.SPEED: 0,
		Stats.LUCK: 0,
		Stats.DEFENSE: 0,
		Stats.ARMOR: 0,
		Stats.RESISTANCE: 0,
		Stats.MOVEMENT: 0,
		Stats.BUILD: 0,
	}

	_effort_power = 50
	_effort_values = {
		Stats.HIT_POINTS: 100,
		Stats.DEXTERITY: 250,
		Stats.SPEED: 150,
		Stats.LUCK: 200,
		Stats.DEFENSE: 50,
		Stats.ARMOR: 50,
		Stats.RESISTANCE: 150,
		Stats.MOVEMENT: 0,
		Stats.BUILD: 0,
	}
	personal_authority = 1
	super()
