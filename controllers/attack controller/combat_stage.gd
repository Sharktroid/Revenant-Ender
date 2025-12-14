class_name CombatStage
## Object that represents one attack in a round of combat.
extends RefCounted

## The possible results of a combat stage
enum AttackTypes { HIT, MISS, CRIT }

## The unit who is attacking.
var attacker: Unit
## The unit who is being attacked.
var defender: Unit
## The type of attack for this round of combat.
var attack_type: AttackTypes

func _init(attacking_unit: Unit, defending_unit: Unit) -> void:
	attacker = attacking_unit
	defender = defending_unit

func generate_attack_type() -> AttackTypes:
	if attacker.get_hit_rate(defender) > randi_range(0, 99):
		if attacker.get_crit_rate(defender) > randi_range(0, 99):
			return AttackTypes.CRIT
		else:
			return AttackTypes.HIT
	else:
		return AttackTypes.MISS

func get_damage(
	crit: bool, initiation: bool, check_miss: bool = true, check_crit: bool = true
) -> float:
	return attacker.get_displayed_damage(defender, crit, initiation, check_miss, check_crit)
