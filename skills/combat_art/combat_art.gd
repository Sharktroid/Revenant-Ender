@abstract
class_name CombatArt
extends Skill

var _rounds: int = 1


func is_active(_unit: Unit, _target: Unit, _distance: int) -> bool:
	return true


func get_attack_queue(attacker: Unit, defender: Unit) -> Array[CombatStage]:
	return [CombatStage.new(attacker, defender, self, true)]


## Gets the quantity of the unit's current attack stat
func get_attack(unit: Unit) -> int:
	return unit.get_current_attack()


## Gets the quantity of the unit's current attack stat
func get_might(unit: Unit, initiation: bool = false) -> float:
	return unit.get_might(initiation)


## Gets the defender's defense type against a weapon
func get_defense(attacker: Unit, defender: Unit) -> int:
	match attacker.get_weapon().get_damage_type():
		Weapon.DamageTypes.PHYSICAL:
			return defender.get_defense()
		Weapon.DamageTypes.RANGED:
			return defender.get_armor()
		Weapon.DamageTypes.MAGICAL:
			return defender.get_resistance()
		var damage_type:
			push_error("Damage Type %s Invalid" % damage_type)
			return 0


## Gets the damage done with a normal attack
func get_damage(attack: float, defense: float, _hp: int) -> float:
	return attack - defense


## Gets the damage done with a crit
func get_crit_damage(attack: float, defense: float) -> float:
	return attack * 2 - defense


func get_rounds() -> int:
	return _rounds
