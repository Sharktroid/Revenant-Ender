@abstract
class_name CombatArt
extends Skill

var _additional_primary_strikes: int


func is_active(_unit: Unit, _target: Unit) -> bool:
	return true


func get_additional_primary_strikes() -> int:
	return _additional_primary_strikes
