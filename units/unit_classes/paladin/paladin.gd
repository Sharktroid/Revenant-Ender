@tool
class_name Paladin
extends MountedUnit


func _init():
	name = "Paladin"
	max_level = 30
	movement_type = movement_types.ADVANCED_HEAVY_CAVALRY
	weight_modifier = 25
	description = "Dedicated cavaliers with superior abilities all around."

	weapon_levels = {
		Weapon.types.SWORD: Weapon.ranks.D,
		Weapon.types.SPEAR: Weapon.ranks.C,
		Weapon.types.AXE: Weapon.ranks.E,
	}

	base_stats = {
		Unit.stats.HITPOINTS: 19,
		Unit.stats.STRENGTH: 8,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 1,
		Unit.stats.SKILL: 7,
		Unit.stats.SPEED: 7,
		Unit.stats.LUCK: 4,
		Unit.stats.DEFENSE: 7,
		Unit.stats.DURABILITY: 6,
		Unit.stats.RESISTANCE: 6,
		Unit.stats.MOVEMENT: 8,
		Unit.stats.CONSTITUTION: 11,
		Unit.stats.AUTHORITY: 0,
	}
	end_stats = {
		Unit.stats.HITPOINTS: 51,
		Unit.stats.STRENGTH: 28,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 1,
		Unit.stats.SKILL: 25,
		Unit.stats.SPEED: 25,
		Unit.stats.LUCK: 16,
		Unit.stats.DEFENSE: 29,
		Unit.stats.DURABILITY: 27,
		Unit.stats.RESISTANCE: 26,
		Unit.stats.MOVEMENT: 8,
		Unit.stats.CONSTITUTION: 11,
		Unit.stats.AUTHORITY: 0,
	}
	stat_caps = {
		Unit.stats.HITPOINTS: 60,
		Unit.stats.STRENGTH: 31,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 26,
		Unit.stats.SKILL: 30,
		Unit.stats.SPEED: 30,
		Unit.stats.LUCK: 32,
		Unit.stats.DEFENSE: 32,
		Unit.stats.DURABILITY: 32,
		Unit.stats.RESISTANCE: 32,
		Unit.stats.MOVEMENT: 10,
		Unit.stats.CONSTITUTION: 20,
		Unit.stats.AUTHORITY: 0,
	}
	map_sprite = preload("res://units/unit_classes/paladin/paladin.png")
	super()
