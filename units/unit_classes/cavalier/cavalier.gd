@tool
class_name Cavalier
extends MountedUnit


func _init():
	name = "Cavalier"
	max_level = 30
	movement_type = movement_types.ADVANCED_HEAVY_CAVALRY
	weight_modifier = 25
	description = "Dedicated cavalry with superior abilities all around."

	base_weapon_levels = {
		Weapon.types.SWORD: Weapon.ranks.C,
		Weapon.types.SPEAR: Weapon.ranks.C,
		Weapon.types.AXE: Weapon.ranks.D,
	}

	max_weapon_levels = {
		Weapon.types.SWORD: Weapon.ranks.S,
		Weapon.types.SPEAR: Weapon.ranks.S,
		Weapon.types.AXE: Weapon.ranks.A,
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
		Unit.stats.MOVEMENT: 9,
		Unit.stats.CONSTITUTION: 11,
	}
	end_stats = {
		Unit.stats.HITPOINTS: 51,
		Unit.stats.STRENGTH: 28,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 22,
		Unit.stats.SKILL: 25,
		Unit.stats.SPEED: 25,
		Unit.stats.LUCK: 16,
		Unit.stats.DEFENSE: 29,
		Unit.stats.DURABILITY: 27,
		Unit.stats.RESISTANCE: 26,
		Unit.stats.MOVEMENT: 9,
		Unit.stats.CONSTITUTION: 11,
	}
	super()
