@tool
class_name Brigand
extends UnitClass


# Unit-specific variables.
func _init() -> void:
	resource_name = "Brigand"
	_max_level = 20
	_movement_type = MovementTypes.BANDITS
	_description = "Mighty mountaineers who prefer axes in combat."

	_base_weapon_levels[Weapon.Types.AXE] = Weapon.Ranks.D
	_max_weapon_levels[Weapon.Types.AXE] = Weapon.Ranks.A

	_base_stats = {
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
	_end_stats = {
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
