class_name Adept
extends StaticClass

class Alpha extends CombatArt:
	func _init() -> void:
		_name = "Adept α"


	func is_active(unit: Unit, target: Unit) -> bool:
		return unit.get_attack_speed() >= target.get_attack_speed()


	func get_attack_queue(attacker: Unit, defender: Unit) -> Array[CombatStage]:
		return [CombatStage.new(attacker, defender), CombatStage.new(attacker, defender)]

class Omega extends Adept.Alpha:
	func _init() -> void:
		_name = "Adept ω"


	func get_attack_queue(attacker: Unit, defender: Unit) -> Array[CombatStage]:
		return [CombatStage.new(attacker, defender), CritStage.new(attacker, defender)]


	class CritStage:
		extends CombatStage

		func get_crit_rate() -> int:
			return 100
