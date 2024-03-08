@tool
class_name Fighter
extends UnitClass


# Unit-specific variables.
func _init():
	name = "Fighter"
	max_level = 20
	movement_type = movement_types.FIGHTERS
	description = "Axe-wielding soldiers whose attack offers little defense."

	base_weapon_levels[Weapon.types.AXE] = Weapon.ranks.D
	max_weapon_levels[Weapon.types.AXE] = Weapon.ranks.A

	base_stats = {
		Unit.stats.HITPOINTS: 23,
		Unit.stats.STRENGTH: 7,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 6,
		Unit.stats.SPEED: 6,
		Unit.stats.LUCK: 2,
		Unit.stats.DEFENSE: 4,
		Unit.stats.DURABILITY: 2,
		Unit.stats.RESISTANCE: 1,
		Unit.stats.MOVEMENT: 6,
		Unit.stats.CONSTITUTION: 11,
	}
	end_stats = {
		Unit.stats.HITPOINTS: 47,
		Unit.stats.STRENGTH: 24,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 23,
		Unit.stats.SPEED: 21,
		Unit.stats.LUCK: 15,
		Unit.stats.DEFENSE: 20,
		Unit.stats.DURABILITY: 16,
		Unit.stats.RESISTANCE: 17,
		Unit.stats.MOVEMENT: 6,
		Unit.stats.CONSTITUTION: 11,
	}
	super()
