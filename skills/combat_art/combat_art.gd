@abstract
class_name CombatArt
extends Skill

var _rounds: int = 1
var _bonus_strikes: int = 0
var _recoil_modifier: float = 0


func is_active(_unit: Unit, _target: Unit, _distance: int) -> bool:
	return true


func get_attack_queue(combat: Combat) -> Array[Combat.Stage]:
	return [Combat.Stage.new(combat, true, true, true)]


## Gets the quantity of the unit's current attack stat
func get_attack(unit: Unit) -> int:
	return unit.get_current_attack()


## Gets the quantity of the unit's current attack stat
func get_might(unit: Unit, initiation: bool = false) -> float:
	return unit.get_might(initiation)


## Gets the defender's defense type against a weapon
func get_defense(base_defense: int, _defender: Unit) -> int:
	return base_defense


## Gets the damage done with a normal attack
func get_damage(attack: float, defense: float, _hp: int) -> float:
	return attack - defense


func get_rounds() -> int:
	return _rounds


func get_hit(unit: Unit) -> float:
	return unit.get_hit()


func get_avoid(unit: Unit) -> float:
	return unit.get_avoid()


func get_bonus_strikes() -> int:
	return _bonus_strikes


func get_recoil_modifier() -> float:
	return _recoil_modifier


func finish(_attacker: Unit, _defender: Unit) -> void:
	pass
