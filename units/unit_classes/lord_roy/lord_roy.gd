@tool
class_name LordRoy
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	name = "Lord"
	description = "A noble attached to a ruling house. Has great potential."
	max_level = 20
	movement_type = MovementTypes.ADVANCED_FOOT

	base_weapon_levels[Weapon.Types.SWORD] = Weapon.Ranks.D
	max_weapon_levels[Weapon.Types.SWORD] = Weapon.Ranks.A

	base_stats = {
		Unit.Stats.HIT_POINTS: 23,
		Unit.Stats.STRENGTH: 6,
		Unit.Stats.PIERCE: 0,
		Unit.Stats.MAGIC: 0,
		Unit.Stats.SKILL: 5,
		Unit.Stats.SPEED: 6,
		Unit.Stats.LUCK: 0,
		Unit.Stats.DEFENSE: 7,
		Unit.Stats.ARMOR: 0,
		Unit.Stats.RESISTANCE: 0,
		Unit.Stats.MOVEMENT: 6,
		Unit.Stats.CONSTITUTION: 6,
	}
	end_stats = {
		Unit.Stats.HIT_POINTS: 44,
		Unit.Stats.STRENGTH: 23,
		Unit.Stats.PIERCE: 0,
		Unit.Stats.MAGIC: 0,
		Unit.Stats.SKILL: 23,
		Unit.Stats.SPEED: 24,
		Unit.Stats.LUCK: 25,
		Unit.Stats.DEFENSE: 21,
		Unit.Stats.ARMOR: 19,
		Unit.Stats.RESISTANCE: 18,
		Unit.Stats.MOVEMENT: 6,
		Unit.Stats.CONSTITUTION: 6,
	}
	super()
