@abstract
class_name CombatArt
extends Skill


func is_active(_unit: Unit, _target: Unit) -> bool:
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
