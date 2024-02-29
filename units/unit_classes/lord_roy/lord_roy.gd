@tool
class_name LordRoy
extends UnitClass


# Unit-specific variables.
func _init():
	name = "Lord"
	description = "A noble attached to a ruling house. Has great potential."
	max_level = 20
	movement_type = movement_types.ADVANCED_FOOT
	weapon_levels[Weapon.types.SWORD] = 1
	base_stats = {
		Unit.stats.HITPOINTS: 23,
		Unit.stats.STRENGTH: 6,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 5,
		Unit.stats.SPEED: 6,
		Unit.stats.LUCK: 0,
		Unit.stats.DEFENSE: 7,
		Unit.stats.DURABILITY: 0,
		Unit.stats.RESISTANCE: 0,
		Unit.stats.MOVEMENT: 6,
		Unit.stats.CONSTITUTION: 6,
	}
	end_stats = {
		Unit.stats.HITPOINTS: 44,
		Unit.stats.STRENGTH: 23,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 23,
		Unit.stats.SPEED: 24,
		Unit.stats.LUCK: 25,
		Unit.stats.DEFENSE: 21,
		Unit.stats.DURABILITY: 19,
		Unit.stats.RESISTANCE: 18,
		Unit.stats.MOVEMENT: 6,
		Unit.stats.CONSTITUTION: 6,
	}
	map_sprite = preload("res://units/unit_classes/lord_roy/lord_roy.png")
