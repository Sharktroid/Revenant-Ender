@tool
class_name SocialKnight
extends MountedUnit


# Unit-specific variables.
func _init() -> void:
	name = "Social Knight"
	max_level = 20
	movement_type = MovementTypes.HEAVY_CAVALRY
	weight_modifier = 25
	description = "Mounted knights with superior movement."

	base_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.E,
		Weapon.Types.SPEAR: Weapon.Ranks.D,
	}
	max_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.B,
		Weapon.Types.SPEAR: Weapon.Ranks.A,
	}

	base_stats = {
		Unit.Stats.HIT_POINTS: 17,
		Unit.Stats.STRENGTH: 6,
		Unit.Stats.PIERCE: 0,
		Unit.Stats.MAGIC: 0,
		Unit.Stats.SKILL: 5,
		Unit.Stats.SPEED: 5,
		Unit.Stats.LUCK: 3,
		Unit.Stats.DEFENSE: 5,
		Unit.Stats.ARMOR: 4,
		Unit.Stats.RESISTANCE: 3,
		Unit.Stats.MOVEMENT: 8,
		Unit.Stats.CONSTITUTION: 9,
	}
	end_stats = {
		Unit.Stats.HIT_POINTS: 42,
		Unit.Stats.STRENGTH: 21,
		Unit.Stats.PIERCE: 0,
		Unit.Stats.MAGIC: 0,
		Unit.Stats.SKILL: 21,
		Unit.Stats.SPEED: 19,
		Unit.Stats.LUCK: 15,
		Unit.Stats.DEFENSE: 21,
		Unit.Stats.ARMOR: 19,
		Unit.Stats.RESISTANCE: 18,
		Unit.Stats.MOVEMENT: 8,
		Unit.Stats.CONSTITUTION: 9,
	}
	super()
