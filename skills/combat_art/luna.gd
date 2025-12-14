class_name Luna
extends CombatArt


func _init() -> void:
	_name = "Adept"


func is_active(unit: Unit, target: Unit) -> bool:
	return unit.get_attack_speed() >= target.get_attack_speed()


func get_attack_queue(attacker: Unit, defender: Unit) -> Array[CombatStage]:
	return [LunaStage.new(attacker, defender)]


class LunaStage:
	extends CombatStage

	func generate_attack_type() -> AttackTypes:
		return AttackTypes.CRIT

	func get_damage(
		crit: bool, initiation: bool, check_miss: bool = true, _check_crit: bool = true
	) -> float:
		return attacker.get_damage(defender, initiation)
