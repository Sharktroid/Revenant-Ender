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
		Unit.stats.HITPOINTS: 29,
		Unit.stats.STRENGTH: 11,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 5,
		Unit.stats.SKILL: 13,
		Unit.stats.SPEED: 12,
		Unit.stats.LUCK: 6,
		Unit.stats.DEFENSE: 3,
		Unit.stats.DURABILITY: 6,
		Unit.stats.RESISTANCE: 5,
		Unit.stats.MOVEMENT: 7,
		Unit.stats.CONSTITUTION: 11,
	}
	end_stats = {
		Unit.stats.HITPOINTS: 50,
		Unit.stats.STRENGTH: 28,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 24,
		Unit.stats.SKILL: 30,
		Unit.stats.SPEED: 30,
		Unit.stats.LUCK: 23,
		Unit.stats.DEFENSE: 23,
		Unit.stats.DURABILITY: 26,
		Unit.stats.RESISTANCE: 25,
		Unit.stats.MOVEMENT: 7,
		Unit.stats.CONSTITUTION: 11,
	}

	map_sprite = load("res://units/unit_classes/champion/champion_m.png")
	default_portrait = preload("res://units/unit_classes/champion/portrait.png")
