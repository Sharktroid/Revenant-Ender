@abstract
class_name CombatArt
extends Skill


func is_active(_unit: Unit, _target: Unit) -> bool:
	return true

func get_attack_queue(attacker: Unit, defender: Unit) -> Array[CombatStage]:
	return [CombatStage.new(attacker, defender)]
