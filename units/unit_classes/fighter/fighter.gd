@tool
class_name Fighter
extends UnitClass


# Unit-specific variables.
func _init():
	name = "Fighter"
	max_level = 30
	movement_type = movement_types.FIGHTERS
	base_stats = {
		Unit.stats.HITPOINTS: 19,
		Unit.stats.STRENGTH: 7,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 6,
		Unit.stats.SPEED: 6,
		Unit.stats.LUCK: 2,
		Unit.stats.DEFENSE: 4,
		Unit.stats.DURABILITY: 2,
		Unit.stats.RESISTANCE: 1,
		Unit.stats.MOVEMENT: 5,
		Unit.stats.CONSTITUTION: 0,
		Unit.stats.LEADERSHIP: 0,
	}
	end_stats = {
		Unit.stats.HITPOINTS: 43,
		Unit.stats.STRENGTH: 25,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 23,
		Unit.stats.SPEED: 20,
		Unit.stats.LUCK: 7,
		Unit.stats.DEFENSE: 16,
		Unit.stats.DURABILITY: 12,
		Unit.stats.RESISTANCE: 10,
		Unit.stats.MOVEMENT: 5,
		Unit.stats.CONSTITUTION: 0,
		Unit.stats.LEADERSHIP: 0,
	}
	stat_caps = {
		Unit.stats.HITPOINTS: 45,
		Unit.stats.STRENGTH: 25,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 15,
		Unit.stats.SKILL: 23,
		Unit.stats.SPEED: 22,
		Unit.stats.LUCK: 21,
		Unit.stats.DEFENSE: 19,
		Unit.stats.DURABILITY: 18,
		Unit.stats.RESISTANCE: 18,
		Unit.stats.MOVEMENT: 7,
		Unit.stats.CONSTITUTION: 0,
		Unit.stats.LEADERSHIP: 0,
	}
	map_sprite = load("uid://dgli13fqa0m3n")
