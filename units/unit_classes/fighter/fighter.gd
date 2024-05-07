@tool
class_name Fighter
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	name = "Fighter"
	max_level = 20
	movement_type = MovementTypes.FIGHTERS
	description = "Axe-wielding soldiers whose attack offers little defense."

	base_weapon_levels[Weapon.Types.AXE] = Weapon.Ranks.D
	max_weapon_levels[Weapon.Types.AXE] = Weapon.Ranks.A

	base_stats = {
		Unit.Stats.HIT_POINTS: 23,
		Unit.Stats.STRENGTH: 7,
		Unit.Stats.PIERCE: 0,
		Unit.Stats.MAGIC: 0,
		Unit.Stats.SKILL: 6,
		Unit.Stats.SPEED: 6,
		Unit.Stats.LUCK: 2,
		Unit.Stats.DEFENSE: 4,
		Unit.Stats.ARMOR: 2,
		Unit.Stats.RESISTANCE: 1,
		Unit.Stats.MOVEMENT: 6,
		Unit.Stats.CONSTITUTION: 11,
	}
	end_stats = {
		Unit.Stats.HIT_POINTS: 47,
		Unit.Stats.STRENGTH: 24,
		Unit.Stats.PIERCE: 0,
		Unit.Stats.MAGIC: 0,
		Unit.Stats.SKILL: 23,
		Unit.Stats.SPEED: 21,
		Unit.Stats.LUCK: 15,
		Unit.Stats.DEFENSE: 20,
		Unit.Stats.ARMOR: 16,
		Unit.Stats.RESISTANCE: 17,
		Unit.Stats.MOVEMENT: 6,
		Unit.Stats.CONSTITUTION: 11,
	}
	super()
