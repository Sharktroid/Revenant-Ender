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
		Unit.Stats.HIT_POINTS: 19,
		Unit.Stats.STRENGTH: 8,
		Unit.Stats.PIERCE: 0,
		Unit.Stats.MAGIC: 1,
		Unit.Stats.SKILL: 7,
		Unit.Stats.SPEED: 7,
		Unit.Stats.LUCK: 4,
		Unit.Stats.DEFENSE: 7,
		Unit.Stats.ARMOR: 6,
		Unit.Stats.RESISTANCE: 6,
		Unit.Stats.MOVEMENT: 9,
		Unit.Stats.CONSTITUTION: 11,
	}
	end_stats = {
		Unit.Stats.HIT_POINTS: 51,
		Unit.Stats.STRENGTH: 28,
		Unit.Stats.PIERCE: 0,
		Unit.Stats.MAGIC: 22,
		Unit.Stats.SKILL: 25,
		Unit.Stats.SPEED: 25,
		Unit.Stats.LUCK: 16,
		Unit.Stats.DEFENSE: 29,
		Unit.Stats.ARMOR: 27,
		Unit.Stats.RESISTANCE: 26,
		Unit.Stats.MOVEMENT: 9,
		Unit.Stats.CONSTITUTION: 11,
	}
	super()
