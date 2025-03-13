@tool
extends Unit


# Unit-specific variables.
func _enter_tree() -> void:
	set_weapon_level(Weapon.Types.AXE, Weapon.Ranks.B)
	_personal_values = {
		Stats.HIT_POINTS: 14,
		Stats.STRENGTH: 10,
		Stats.PIERCE: 5,
		Stats.INTELLIGENCE: 5,
		Stats.DEXTERITY: 9,
		Stats.SPEED: 7,
		Stats.LUCK: 5,
		Stats.DEFENSE: 7,
		Stats.ARMOR: 5,
		Stats.RESISTANCE: 5,
		Stats.MOVEMENT: 0,
		Stats.BUILD: 5,
	}
	super()
