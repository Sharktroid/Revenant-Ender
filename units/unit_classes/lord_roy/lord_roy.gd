@tool
class_name LordRoy
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	name = "Lord"
	description = "A noble attached to a ruling house. Has great potential."
	max_level = 20
	movement_type = movementTypes.ADVANCED_FOOT

	base_weapon_levels[Weapon.types.SWORD] = Weapon.ranks.D
	max_weapon_levels[Weapon.types.SWORD] = Weapon.ranks.A

	base_stats = {
		Unit.stats.HIT_POINTS: 23,
		Unit.stats.STRENGTH: 6,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 5,
		Unit.stats.SPEED: 6,
		Unit.stats.LUCK: 0,
		Unit.stats.DEFENSE: 7,
		Unit.stats.ARMOR: 0,
		Unit.stats.RESISTANCE: 0,
		Unit.stats.MOVEMENT: 6,
		Unit.stats.CONSTITUTION: 6,
	}
	end_stats = {
		Unit.stats.HIT_POINTS: 44,
		Unit.stats.STRENGTH: 23,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 23,
		Unit.stats.SPEED: 24,
		Unit.stats.LUCK: 25,
		Unit.stats.DEFENSE: 21,
		Unit.stats.ARMOR: 19,
		Unit.stats.RESISTANCE: 18,
		Unit.stats.MOVEMENT: 6,
		Unit.stats.CONSTITUTION: 6,
	}
	super()
