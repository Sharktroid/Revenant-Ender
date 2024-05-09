@tool
class_name Archer
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	resource_name = "Archer"
	_max_level = 20
	_movement_type = MovementTypes.FOOT
	_description = "Soldiers who attack from a distance with their bows."

	_base_weapon_levels[Weapon.Types.BOW] = Weapon.Ranks.D
	_max_weapon_levels[Weapon.Types.BOW] = Weapon.Ranks.A

	_base_stats = {
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
	_end_stats = {
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
