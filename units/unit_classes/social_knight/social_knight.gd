@tool
class_name SocialKnight
extends MountedUnit


# Unit-specific variables.
func _init() -> void:
	name = "Social Knight"
	max_level = 20
	movement_type = movement_types.HEAVY_CAVALRY
	weight_modifier = 25
	description = "Mounted knights with superior movement."

	base_weapon_levels = {
		Weapon.types.SWORD: Weapon.ranks.E,
		Weapon.types.SPEAR: Weapon.ranks.D,
	}
	max_weapon_levels = {
		Weapon.types.SWORD: Weapon.ranks.B,
		Weapon.types.SPEAR: Weapon.ranks.A,
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
		Unit.stats.MOVEMENT: 8,
		Unit.stats.CONSTITUTION: 9,
	}
	end_stats = {
		Unit.stats.HITPOINTS: 42,
		Unit.stats.STRENGTH: 21,
		Unit.stats.PIERCE: 0,
		Unit.stats.MAGIC: 0,
		Unit.stats.SKILL: 21,
		Unit.stats.SPEED: 19,
		Unit.stats.LUCK: 15,
		Unit.stats.DEFENSE: 21,
		Unit.stats.DURABILITY: 19,
		Unit.stats.RESISTANCE: 18,
		Unit.stats.MOVEMENT: 8,
		Unit.stats.CONSTITUTION: 9,
	}
	super()
