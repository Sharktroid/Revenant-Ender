@tool
class_name Hero
extends UnitClass


func _init() -> void:
	name = "Champion"
	max_level = 30
	movement_type = MovementTypes.ADVANCED_FOOT
	weight_modifier = 1
	description = "An honorific bestowed upon famed mercenary masters."

	base_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.C,
		Weapon.Types.AXE: Weapon.Ranks.C,
	}
	max_weapon_levels = {
		Weapon.Types.SWORD: Weapon.Ranks.S,
		Weapon.Types.AXE: Weapon.Ranks.S,
	}

	base_stats = {
		Unit.Stats.HIT_POINTS: 29,
		Unit.Stats.STRENGTH: 11,
		Unit.Stats.PIERCE: 0,
		Unit.Stats.MAGIC: 5,
		Unit.Stats.SKILL: 13,
		Unit.Stats.SPEED: 12,
		Unit.Stats.LUCK: 6,
		Unit.Stats.DEFENSE: 5,
		Unit.Stats.ARMOR: 3,
		Unit.Stats.RESISTANCE: 6,
		Unit.Stats.MOVEMENT: 7,
		Unit.Stats.CONSTITUTION: 11,
	}
	end_stats = {
		Unit.Stats.HIT_POINTS: 50,
		Unit.Stats.STRENGTH: 28,
		Unit.Stats.PIERCE: 0,
		Unit.Stats.MAGIC: 24,
		Unit.Stats.SKILL: 30,
		Unit.Stats.SPEED: 30,
		Unit.Stats.LUCK: 23,
		Unit.Stats.DEFENSE: 24,
		Unit.Stats.ARMOR: 20,
		Unit.Stats.RESISTANCE: 26,
		Unit.Stats.MOVEMENT: 7,
		Unit.Stats.CONSTITUTION: 11,
	}

	map_sprite = load("res://units/unit_classes/champion/champion_m.png")
