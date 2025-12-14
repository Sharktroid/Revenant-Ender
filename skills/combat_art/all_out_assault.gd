class_name AllOutAssault
extends CombatArt


func _init() -> void:
	_name = "All-Out Assault"


func get_attack_queue(attacker: Unit, defender: Unit) -> Array[CombatStage]:
	return [
		CombatStage.new(attacker, defender),
		CombatStage.new(attacker, defender),
		CombatStage.new(attacker, defender),
		CritStage.new(attacker, defender)
	]


class CritStage:
	extends CombatStage

	func generate_attack_type() -> AttackTypes:
		return AttackTypes.CRIT

	func get_damage(
		_crit: bool, initiation: bool, check_miss: bool = true, check_crit: bool = true
	) -> float:
		return attacker.get_displayed_damage(defender, true, initiation, check_miss, false)
