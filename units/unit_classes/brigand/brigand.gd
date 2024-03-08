@tool
class_name Brigand
extends UnitClass


# Unit-specific variables.
func _init():
	name = "Brigand"
	max_level = 20
	movement_type = movement_types.BANDITS
	description = "Mighty mountaineers who prefer axes in combat."

	base_weapon_levels[Weapon.types.AXE] = Weapon.ranks.D
	max_weapon_levels[Weapon.types.AXE] = Weapon.ranks.A

	base_stats = {
		Unit.stats.HITPOINTS: 25,
		Unit.stats.STRENGTH: 8,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 2,
		Unit.stats.SPEED: 5,
		Unit.stats.LUCK: 0,
		Unit.stats.DEFENSE: 4,
		Unit.stats.DURABILITY: 1,
		Unit.stats.RESISTANCE: 0,
		Unit.stats.MOVEMENT: 6,
		Unit.stats.CONSTITUTION: 12,
	}
	end_stats = {
		Unit.stats.HITPOINTS: 50,
		Unit.stats.STRENGTH: 25,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 15,
		Unit.stats.SKILL: 16,
		Unit.stats.SPEED: 21,
		Unit.stats.LUCK: 18,
		Unit.stats.DEFENSE: 20,
		Unit.stats.DURABILITY: 16,
		Unit.stats.RESISTANCE: 15,
		Unit.stats.MOVEMENT: 6,
		Unit.stats.CONSTITUTION: 12,
	}
	super()
