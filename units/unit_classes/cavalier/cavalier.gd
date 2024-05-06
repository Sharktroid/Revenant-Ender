@tool
class_name Cavalier
extends MountedUnit


func _init() -> void:
	name = "Cavalier"
	max_level = 30
	movement_type = MovementTypes.ADVANCED_HEAVY_CAVALRY
	weight_modifier = 25
	description = "Dedicated cavalry with superior abilities all around."

	base_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.C,
		Weapon.Types.SPEAR: Weapon.Ranks.C,
		Weapon.Types.AXE: Weapon.Ranks.D,
	}

	max_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.S,
		Weapon.Types.SPEAR: Weapon.Ranks.S,
		Weapon.Types.AXE: Weapon.Ranks.A,
	}

	base_stats = {
		Unit.stats.HIT_POINTS: 19,
		Unit.stats.STRENGTH: 8,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 1,
		Unit.stats.SKILL: 7,
		Unit.stats.SPEED: 7,
		Unit.stats.LUCK: 4,
		Unit.stats.DEFENSE: 7,
		Unit.stats.ARMOR: 6,
		Unit.stats.RESISTANCE: 6,
		Unit.stats.MOVEMENT: 9,
		Unit.stats.CONSTITUTION: 11,
	}
	end_stats = {
		Unit.stats.HIT_POINTS: 51,
		Unit.stats.STRENGTH: 28,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 22,
		Unit.stats.SKILL: 25,
		Unit.stats.SPEED: 25,
		Unit.stats.LUCK: 16,
		Unit.stats.DEFENSE: 29,
		Unit.stats.ARMOR: 27,
		Unit.stats.RESISTANCE: 26,
		Unit.stats.MOVEMENT: 9,
		Unit.stats.CONSTITUTION: 11,
	}
	super()
