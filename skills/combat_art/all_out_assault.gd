class_name AllOutAssault
extends CombatArt


func _init() -> void:
	_name = "All-Out Assault"


func get_attack_queue(attacker: Unit, defender: Unit) -> Array[CombatStage]:
	return [
		CombatStage.new(attacker, defender),
		CombatStage.new(attacker, defender),
		CritStage.new(attacker, defender)
	]


class CritStage:
	extends CombatStage

	func get_crit_rate() -> int:
		return 100
