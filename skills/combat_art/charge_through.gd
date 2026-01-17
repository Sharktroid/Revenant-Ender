class_name ChargeThrough
extends CombatArt


func _init() -> void:
	_name = "Charge Through"


func finish(attacker: Unit, defender: Unit) -> void:
	attacker.position += (defender.position - attacker.position) * 2


func is_active(_unit: Unit, _target: Unit, _distance: int) -> bool:
	return _distance == 1
