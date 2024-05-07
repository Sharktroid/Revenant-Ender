@tool
class_name Archer
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	name = "Archer"
	max_level = 20
	movement_type = MovementTypes.FOOT
	description = "Soldiers who attack from a distance with their bows."

	base_weapon_levels[Weapon.Types.BOW] = Weapon.Ranks.D
	max_weapon_levels[Weapon.Types.BOW] = Weapon.Ranks.A

	base_stats = {
		Unit.Stats.HIT_POINTS: 23,
		Unit.Stats.STRENGTH: 0,
		Unit.Stats.PIERCE: 5,
		Unit.Stats.MAGIC: 3,
		Unit.Stats.SKILL: 6,
		Unit.Stats.SPEED: 5,
		Unit.Stats.LUCK: 4,
		Unit.Stats.DEFENSE: 2,
		Unit.Stats.ARMOR: 7,
		Unit.Stats.RESISTANCE: 6,
		Unit.Stats.MOVEMENT: 6,
		Unit.Stats.CONSTITUTION: 7,
	}
	end_stats = {
		Unit.Stats.HIT_POINTS: 42,
		Unit.Stats.STRENGTH: 0,
		Unit.Stats.PIERCE: 21,
		Unit.Stats.MAGIC: 17,
		Unit.Stats.SKILL: 24,
		Unit.Stats.SPEED: 19,
		Unit.Stats.LUCK: 23,
		Unit.Stats.DEFENSE: 16,
		Unit.Stats.ARMOR: 25,
		Unit.Stats.RESISTANCE: 25,
		Unit.Stats.MOVEMENT: 6,
		Unit.Stats.CONSTITUTION: 7,
	}
	super()
