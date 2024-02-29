@tool
class_name Hero
extends UnitClass


func _init():
	name = "Champion"
	max_level = 30
	movement_type = movement_types.ADVANCED_FOOT
	weight_modifier = 1
	description = "An honorific bestowed upon famed mercenary masters."

	weapon_levels = {
		Weapon.types.SWORD: Weapon.ranks.C,
		Weapon.types.AXE: Weapon.ranks.D,
	}

	base_stats = {
		Unit.stats.HITPOINTS: 20,
		Unit.stats.STRENGTH: 8,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 10,
		Unit.stats.SPEED: 8,
		Unit.stats.LUCK: 3,
		Unit.stats.DEFENSE: 3,
		Unit.stats.DURABILITY: 5,
		Unit.stats.RESISTANCE: 5,
		Unit.stats.MOVEMENT: 6,
		Unit.stats.CONSTITUTION: 11,
	}
	end_stats = {
		Unit.stats.HITPOINTS: 56,
		Unit.stats.STRENGTH: 28,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 35,
		Unit.stats.SPEED: 30,
		Unit.stats.LUCK: 15,
		Unit.stats.DEFENSE: 20,
		Unit.stats.DURABILITY: 26,
		Unit.stats.RESISTANCE: 25,
		Unit.stats.MOVEMENT: 6,
		Unit.stats.CONSTITUTION: 11,
	}

	map_sprite = load("res://units/unit_classes/champion/champion_m.png")
	default_portrait = preload("res://units/unit_classes/champion/portrait.png")
