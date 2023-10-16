@tool
class_name SocialKnight
extends MountedUnit


# Unit-specific variables.
func _init():
	name = "Social Knight"
	max_level = 30
	movement_type = movement_types.HEAVY_CAVALRY
	weight_modifier = 25
	description = "Mounted knights with superior movement."

	weapon_levels = {
		Weapon.types.SWORD: Weapon.ranks.E,
		Weapon.types.SPEAR: Weapon.ranks.D,
	}

	base_stats = {
		Unit.stats.HITPOINTS: 17,
		Unit.stats.STRENGTH: 6,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 5,
		Unit.stats.SPEED: 5,
		Unit.stats.LUCK: 3,
		Unit.stats.DEFENSE: 5,
		Unit.stats.DURABILITY: 4,
		Unit.stats.RESISTANCE: 3,
		Unit.stats.MOVEMENT: 7,
		Unit.stats.CONSTITUTION: 9,
		Unit.stats.AUTHORITY: 0,
	}
	end_stats = {
		Unit.stats.HITPOINTS: 38,
		Unit.stats.STRENGTH: 21,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 19,
		Unit.stats.SPEED: 17,
		Unit.stats.LUCK: 12,
		Unit.stats.DEFENSE: 20,
		Unit.stats.DURABILITY: 18,
		Unit.stats.RESISTANCE: 17,
		Unit.stats.MOVEMENT: 7,
		Unit.stats.CONSTITUTION: 9,
		Unit.stats.AUTHORITY: 0,
	}
	stat_caps = {
		Unit.stats.HITPOINTS: 40,
		Unit.stats.STRENGTH: 22,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 15,
		Unit.stats.SKILL: 21,
		Unit.stats.SPEED: 20,
		Unit.stats.LUCK: 24,
		Unit.stats.DEFENSE: 22,
		Unit.stats.DURABILITY: 21,
		Unit.stats.RESISTANCE: 21,
		Unit.stats.MOVEMENT: 9,
		Unit.stats.CONSTITUTION: 20,
		Unit.stats.AUTHORITY: 0,
	}
	map_sprite = load("uid://dcbp6yac31ins")
	super()
