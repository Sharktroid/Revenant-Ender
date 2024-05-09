@tool
class_name Hoplite
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	resource_name = "Hoplite"
	_max_level = 20
	_movement_type = MovementTypes.ARMOR
	_weight_modifier = 5
	_description = "Heavily armored knights with stout defense, but low speed."

	_base_weapon_levels[Weapon.Types.SPEAR] = Weapon.Ranks.D
	_max_weapon_levels[Weapon.Types.SPEAR] = Weapon.Ranks.A

	_base_stats = {
		Unit.Stats.HIT_POINTS: 19,
		Unit.Stats.STRENGTH: 8,
		Unit.Stats.PIERCE: 0,
		Unit.Stats.MAGIC: 0,
		Unit.Stats.SKILL: 5,
		Unit.Stats.SPEED: 3,
		Unit.Stats.LUCK: 3,
		Unit.Stats.DEFENSE: 8,
		Unit.Stats.ARMOR: 5,
		Unit.Stats.RESISTANCE: 1,
		Unit.Stats.MOVEMENT: 6,
		Unit.Stats.CONSTITUTION: 13,
	}
	_end_stats = {
		Unit.Stats.HIT_POINTS: 50,
		Unit.Stats.STRENGTH: 22,
		Unit.Stats.PIERCE: 0,
		Unit.Stats.MAGIC: 0,
		Unit.Stats.SKILL: 21,
		Unit.Stats.SPEED: 15,
		Unit.Stats.LUCK: 24,
		Unit.Stats.DEFENSE: 25,
		Unit.Stats.ARMOR: 24,
		Unit.Stats.RESISTANCE: 17,
		Unit.Stats.MOVEMENT: 6,
		Unit.Stats.CONSTITUTION: 13,
	}
	super()

