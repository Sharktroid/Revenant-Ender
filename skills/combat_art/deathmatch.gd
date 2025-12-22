class_name Deathmatch
extends CombatArt


func _init() -> void:
	_name = "Deathmatch"
	_rounds = 5


func is_active(_unit: Unit, target: Unit, distance: int) -> bool:
	if target and target.get_weapon():
		return target.get_weapon().in_range(distance)
	return false
