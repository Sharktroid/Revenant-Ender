@tool
class_name Hoplite
extends UnitClass


# Unit-specific variables.
func _init():
	name = "Hoplite"
	max_level = 30
	movement_type = movement_types.ARMOR
	weapon_levels[Weapon.types.SPEAR] = Weapon.ranks.D
	base_stats = {
		Unit.stats.HITPOINTS: 19,
		Unit.stats.STRENGTH: 8,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 5,
		Unit.stats.SPEED: 3,
		Unit.stats.LUCK: 3,
		Unit.stats.DEFENSE: 8,
		Unit.stats.DURABILITY: 5,
		Unit.stats.RESISTANCE: 1,
		Unit.stats.MOVEMENT: 4,
		Unit.stats.CONSTITUTION: 13,
		Unit.stats.AUTHORITY: 0
	}
	end_stats = {
		Unit.stats.HITPOINTS: 43,
		Unit.stats.STRENGTH: 25,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 19,
		Unit.stats.SPEED: 11,
		Unit.stats.LUCK: 12.0,
		Unit.stats.DEFENSE: 23,
		Unit.stats.DURABILITY: 20,
		Unit.stats.RESISTANCE: 10,
		Unit.stats.MOVEMENT: 4,
		Unit.stats.CONSTITUTION: 13,
		Unit.stats.AUTHORITY: 0
	}
	stat_caps = {
		Unit.stats.HITPOINTS: 60,
		Unit.stats.STRENGTH: 20,
		Unit.stats.PIERCE: 20,
		Unit.stats.MAGIC: 20,
		Unit.stats.SKILL: 20,
		Unit.stats.SPEED: 17,
		Unit.stats.LUCK: 22,
		Unit.stats.DEFENSE: 26,
		Unit.stats.DURABILITY: 24,
		Unit.stats.RESISTANCE: 18,
		Unit.stats.MOVEMENT: 15,
		Unit.stats.CONSTITUTION: 20,
		Unit.stats.AUTHORITY: 5
	}
	map_sprite = load("uid://ybdk2ivoxxyj")

