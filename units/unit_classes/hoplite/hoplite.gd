@tool
class_name Hoplite
extends UnitClass


# Unit-specific variables.
func _init():
	name = "Hoplite"
	max_level = 20
	movement_type = movement_types.ARMOR
	weight_modifier = 5
	description = "Heavily armored knights with stout defense, but low speed."

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
	}
	map_sprite = preload("res://units/unit_classes/hoplite/hoplite.png")

