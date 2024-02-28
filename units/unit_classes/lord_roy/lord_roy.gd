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
		Unit.stats.HITPOINTS: 18,
		Unit.stats.STRENGTH: 6,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 5,
		Unit.stats.SPEED: 6,
		Unit.stats.LUCK: 0,
		Unit.stats.DEFENSE: 7,
		Unit.stats.DURABILITY: 0,
		Unit.stats.RESISTANCE: 0,
		Unit.stats.MOVEMENT: 5,
		Unit.stats.CONSTITUTION: 6,
	}
	end_stats = {
		Unit.stats.HITPOINTS: 39,
		Unit.stats.STRENGTH: 18,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 14,
		Unit.stats.SPEED: 15,
		Unit.stats.LUCK: 12,
		Unit.stats.DEFENSE: 15,
		Unit.stats.DURABILITY: 0,
		Unit.stats.RESISTANCE: 6,
		Unit.stats.MOVEMENT: 5,
		Unit.stats.CONSTITUTION: 6,
	}
	stat_caps = {
		Unit.stats.HITPOINTS: 60,
		Unit.stats.STRENGTH: 27,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 20,
		Unit.stats.SKILL: 25,
		Unit.stats.SPEED: 26,
		Unit.stats.LUCK: 30,
		Unit.stats.DEFENSE: 26,
		Unit.stats.DURABILITY: 0,
		Unit.stats.RESISTANCE: 25,
		Unit.stats.MOVEMENT: 7,
		Unit.stats.CONSTITUTION: 20,
	}
	map_sprite = preload("res://units/unit_classes/lord_roy/lord_roy.png")
