@tool
extends Unit


# Unit-specific variables.
func _init() -> void:
	weapon_levels[Weapon.types.SPEAR] = Weapon.ranks.A
	personal_values = {
		Unit.stats.HIT_POINTS: 0,
		Unit.stats.STRENGTH: 0,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 0,
		Unit.stats.SPEED: 0,
		Unit.stats.LUCK: 0,
		Unit.stats.DEFENSE: 0,
		Unit.stats.ARMOR: 0,
		Unit.stats.RESISTANCE: 0,
		Unit.stats.MOVEMENT: 0,
		Unit.stats.CONSTITUTION: 0,
	}
	effort_values = {
		Unit.stats.HIT_POINTS: 100,
		Unit.stats.STRENGTH: 50,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 250,
		Unit.stats.SPEED: 150,
		Unit.stats.LUCK: 200,
		Unit.stats.DEFENSE: 50,
		Unit.stats.ARMOR: 50,
		Unit.stats.RESISTANCE: 150,
		Unit.stats.MOVEMENT: 0,
		Unit.stats.CONSTITUTION: 0,
	}
	personal_authority = 1

