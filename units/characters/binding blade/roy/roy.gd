@tool
extends Unit


# Unit-specific variables.
func _init() -> void:
	weapon_levels[Weapon.types.SWORD] = Weapon.ranks.C
	personal_values = {
		Unit.stats.HITPOINTS: 5,
		Unit.stats.STRENGTH: 5,
		Unit.stats.PIERCE: 5,
		Unit.stats.MAGIC: 5,
		Unit.stats.SKILL: 5,
		Unit.stats.SPEED: 8,
		Unit.stats.LUCK: 12,
		Unit.stats.DEFENSE: 5,
		Unit.stats.DURABILITY: 5,
		Unit.stats.RESISTANCE: 5,
		Unit.stats.MOVEMENT: 5,
		Unit.stats.CONSTITUTION: 5,
		Unit.stats.AUTHORITY: 5,
	}
	effort_values = {
		Unit.stats.HITPOINTS: 0,
		Unit.stats.STRENGTH: 0,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 0,
		Unit.stats.SPEED: 0,
		Unit.stats.LUCK: 0,
		Unit.stats.DEFENSE: 0,
		Unit.stats.DURABILITY: 0,
		Unit.stats.RESISTANCE: 0,
		Unit.stats.MOVEMENT: 0,
		Unit.stats.CONSTITUTION: 0,
		Unit.stats.AUTHORITY: 0,
	}

