class_name Dragonhaze
extends CombatArt


func _init() -> void:
	_name = "Dragonhaze"


func is_active(unit: Unit, target: Unit, _distance: int) -> bool:
	return unit.get_attack_speed() > target.get_attack_speed()


func get_attack(unit: Unit, target: Unit) -> int:
	return super(unit, target) + roundi(unit.get_attack_speed() - target.get_attack_speed()) * 2
