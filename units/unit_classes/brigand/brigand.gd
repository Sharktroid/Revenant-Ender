@tool
class_name Brigand
extends UnitClass


# Unit-specific variables.
func _init():
	name = "Brigand"
	max_level = 20
	movement_type = movement_types.BANDITS
	description = "Mighty mountaineers who prefer axes in combat."

	weapon_levels[Weapon.types.AXE] = Weapon.ranks.D

	base_stats = {
		Unit.stats.HITPOINTS: 18,
		Unit.stats.STRENGTH: 6,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 1,
		Unit.stats.SKILL: 2,
		Unit.stats.SPEED: 5,
		Unit.stats.LUCK: 0,
		Unit.stats.DEFENSE: 7,
		Unit.stats.DURABILITY: 2,
		Unit.stats.RESISTANCE: 1,
		Unit.stats.MOVEMENT: 5,
		Unit.stats.CONSTITUTION: 12,
	}
	end_stats = {
		Unit.stats.HITPOINTS: 34,
		Unit.stats.STRENGTH: 18,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 1,
		Unit.stats.SKILL: 9,
		Unit.stats.SPEED: 12,
		Unit.stats.LUCK: 3,
		Unit.stats.DEFENSE: 16,
		Unit.stats.DURABILITY: 9,
		Unit.stats.RESISTANCE: 7,
		Unit.stats.MOVEMENT: 5,
		Unit.stats.CONSTITUTION: 12,
	}
	map_sprite = preload("res://units/unit_classes/brigand/brigand.png")
	default_portrait = preload("res://units/unit_classes/brigand/portrait.png")
