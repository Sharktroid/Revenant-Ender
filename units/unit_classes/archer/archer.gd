@tool
class_name Archer
extends UnitClass


# Unit-specific variables.
func _init():
	name = "Archer"
	max_level = 20
	movement_type = movement_types.FOOT
	description = "Soldiers who attack from a distance with their bows."

	weapon_levels[Weapon.types.BOW] = Weapon.ranks.D

	base_stats = {
		Unit.stats.HITPOINTS: 23,
		Unit.stats.STRENGTH: 0,
		Unit.stats.PIERCE: 5,
		Unit.stats.MAGIC: 3,
		Unit.stats.SKILL: 6,
		Unit.stats.SPEED: 5,
		Unit.stats.LUCK: 4,
		Unit.stats.DEFENSE: 2,
		Unit.stats.DURABILITY: 7,
		Unit.stats.RESISTANCE: 6,
		Unit.stats.MOVEMENT: 6,
		Unit.stats.CONSTITUTION: 7,
	}
	end_stats = {
		Unit.stats.HITPOINTS: 42,
		Unit.stats.STRENGTH: 0,
		Unit.stats.PIERCE: 21,
		Unit.stats.MAGIC: 17,
		Unit.stats.SKILL: 24,
		Unit.stats.SPEED: 19,
		Unit.stats.LUCK: 23,
		Unit.stats.DEFENSE: 16,
		Unit.stats.DURABILITY: 25,
		Unit.stats.RESISTANCE: 25,
		Unit.stats.MOVEMENT: 6,
		Unit.stats.CONSTITUTION: 7,
	}
	super()
