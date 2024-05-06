@tool
class_name Hoplite
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	name = "Hoplite"
	max_level = 20
	movement_type = MovementTypes.ARMOR
	weight_modifier = 5
	description = "Heavily armored knights with stout defense, but low speed."

	base_weapon_levels[Weapon.Types.SPEAR] = Weapon.Ranks.D
	max_weapon_levels[Weapon.Types.SPEAR] = Weapon.Ranks.A

	base_stats = {
		Unit.stats.HIT_POINTS: 19,
		Unit.stats.STRENGTH: 8,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 5,
		Unit.stats.SPEED: 3,
		Unit.stats.LUCK: 3,
		Unit.stats.DEFENSE: 8,
		Unit.stats.ARMOR: 5,
		Unit.stats.RESISTANCE: 1,
		Unit.stats.MOVEMENT: 6,
		Unit.stats.CONSTITUTION: 13,
	}
	end_stats = {
		Unit.stats.HIT_POINTS: 50,
		Unit.stats.STRENGTH: 22,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 21,
		Unit.stats.SPEED: 15,
		Unit.stats.LUCK: 24,
		Unit.stats.DEFENSE: 25,
		Unit.stats.ARMOR: 24,
		Unit.stats.RESISTANCE: 17,
		Unit.stats.MOVEMENT: 6,
		Unit.stats.CONSTITUTION: 13,
	}
	super()

