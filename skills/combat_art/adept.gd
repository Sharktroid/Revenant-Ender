class_name Adept
extends CombatArt


func _init() -> void:
	_name = "Adept"


func is_active(unit: Unit, target: Unit) -> bool:
	return unit.get_attack_speed() >= target.get_attack_speed()


func get_attack_queue(attacker: Unit, defender: Unit) -> Array[CombatStage]:
	return [CombatStage.new(attacker, defender), CombatStage.new(attacker, defender)]
