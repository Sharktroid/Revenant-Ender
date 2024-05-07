@tool
extends Unit


# Unit-specific variables.
func _init() -> void:
	weapon_levels[Weapon.Types.SPEAR] = Weapon.Ranks.A
	personal_values = {
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
	effort_values = {
		Unit.Stats.HIT_POINTS: 100,
		Unit.Stats.STRENGTH: 50,
		Unit.Stats.PIERCE: 0,
		Unit.Stats.MAGIC: 0,
		Unit.Stats.SKILL: 250,
		Unit.Stats.SPEED: 150,
		Unit.Stats.LUCK: 200,
		Unit.Stats.DEFENSE: 50,
		Unit.Stats.ARMOR: 50,
		Unit.Stats.RESISTANCE: 150,
		Unit.Stats.MOVEMENT: 0,
		Unit.Stats.CONSTITUTION: 0,
	}
	personal_authority = 1

