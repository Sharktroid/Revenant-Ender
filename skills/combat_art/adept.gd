class_name Adept
extends StaticClass

class Alpha extends CombatArt:
	func _init() -> void:
		_name = "Adept α"


	func is_active(unit: Unit, target: Unit, _distance: int) -> bool:
		return unit.get_attack_speed() >= target.get_attack_speed()


	func get_attack_queue(combat: Combat) -> Array[CombatStage]:
		return [CombatStage.new(combat, true, true, true), CombatStage.new(combat, true, true)]

class Omega extends Alpha:
	func _init() -> void:
		_name = "Adept ω"


	func get_attack_queue(combat: Combat) -> Array[CombatStage]:
		return [CombatStage.new(combat, true, true, true), CritStage.new(combat, true, true)]


	class CritStage:
		extends CombatStage

		func get_crit_rate() -> int:
			return 100
