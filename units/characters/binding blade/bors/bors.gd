@tool
extends Unit


# Unit-specific variables.
func _init() -> void:
	personal_base_stats = {
		Unit.stats.HITPOINTS: 3,
		Unit.stats.STRENGTH: 2,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 2,
		Unit.stats.SPEED: 3,
		Unit.stats.LUCK: 4,
		Unit.stats.DEFENSE: 2,
		Unit.stats.DURABILITY: 0,
		Unit.stats.RESISTANCE: 0,
		Unit.stats.MOVEMENT: 0,
		Unit.stats.CONSTITUTION: 0,
		Unit.stats.AUTHORITY: 0,
	}
	personal_end_stats = {
		Unit.stats.HITPOINTS: 3,
		Unit.stats.STRENGTH: 2,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 2,
		Unit.stats.SPEED: 3,
		Unit.stats.LUCK: 4,
		Unit.stats.DEFENSE: 2,
		Unit.stats.DURABILITY: 0,
		Unit.stats.RESISTANCE: 0,
		Unit.stats.MOVEMENT: 0,
		Unit.stats.CONSTITUTION: 0,
		Unit.stats.AUTHORITY: 0,
	}
	personal_stat_caps = {
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

