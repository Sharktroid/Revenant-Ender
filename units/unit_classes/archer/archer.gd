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
		Unit.stats.HITPOINTS: 17,
		Unit.stats.STRENGTH: 0,
		Unit.stats.PIERCE: 5,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 7,
		Unit.stats.SPEED: 5,
		Unit.stats.LUCK: 2,
		Unit.stats.DEFENSE: 2,
		Unit.stats.DURABILITY: 5,
		Unit.stats.RESISTANCE: 4,
		Unit.stats.MOVEMENT: 5,
		Unit.stats.CONSTITUTION: 7,
		Unit.stats.AUTHORITY: 0,
	}
	end_stats = {
		Unit.stats.HITPOINTS: 38,
		Unit.stats.STRENGTH: 0,
		Unit.stats.PIERCE: 19,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 22,
		Unit.stats.SPEED: 16,
		Unit.stats.LUCK: 10,
		Unit.stats.DEFENSE: 14,
		Unit.stats.DURABILITY: 21,
		Unit.stats.RESISTANCE: 18,
		Unit.stats.MOVEMENT: 5,
		Unit.stats.CONSTITUTION: 7,
		Unit.stats.AUTHORITY: 0,
	}
	stat_caps = {
		Unit.stats.HITPOINTS: 40,
		Unit.stats.STRENGTH: 15,
		Unit.stats.PIERCE: 20,
		Unit.stats.MAGIC: 15,
		Unit.stats.SKILL: 20,
		Unit.stats.SPEED: 19,
		Unit.stats.LUCK: 20,
		Unit.stats.DEFENSE: 20,
		Unit.stats.DURABILITY: 23,
		Unit.stats.RESISTANCE: 21,
		Unit.stats.MOVEMENT: 7,
		Unit.stats.CONSTITUTION: 20,
		Unit.stats.AUTHORITY: 0,
	}
	map_sprite = load("uid://dhm1yqcs0uc71")
	default_portrait = load("uid://cmwig2e5y5kim")
