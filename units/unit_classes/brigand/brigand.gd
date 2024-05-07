@tool
class_name Brigand
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	name = "Brigand"
	max_level = 20
	movement_type = MovementTypes.BANDITS
	description = "Mighty mountaineers who prefer axes in combat."

	base_weapon_levels[Weapon.Types.AXE] = Weapon.Ranks.D
	max_weapon_levels[Weapon.Types.AXE] = Weapon.Ranks.A

	base_stats = {
		Unit.Stats.HIT_POINTS: 25,
		Unit.Stats.STRENGTH: 8,
		Unit.Stats.PIERCE: 0,
		Unit.Stats.MAGIC: 0,
		Unit.Stats.SKILL: 2,
		Unit.Stats.SPEED: 5,
		Unit.Stats.LUCK: 0,
		Unit.Stats.DEFENSE: 4,
		Unit.Stats.ARMOR: 1,
		Unit.Stats.RESISTANCE: 0,
		Unit.Stats.MOVEMENT: 6,
		Unit.Stats.CONSTITUTION: 12,
	}
	end_stats = {
		Unit.Stats.HIT_POINTS: 50,
		Unit.Stats.STRENGTH: 25,
		Unit.Stats.PIERCE: 0,
		Unit.Stats.MAGIC: 15,
		Unit.Stats.SKILL: 16,
		Unit.Stats.SPEED: 21,
		Unit.Stats.LUCK: 18,
		Unit.Stats.DEFENSE: 20,
		Unit.Stats.ARMOR: 16,
		Unit.Stats.RESISTANCE: 15,
		Unit.Stats.MOVEMENT: 6,
		Unit.Stats.CONSTITUTION: 12,
	}
	super()
