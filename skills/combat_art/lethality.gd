class_name Lethality
extends CombatArt


func _init() -> void:
	_name = "Lethality"


func is_active(_unit: Unit, target: Unit) -> bool:
	return target.current_health < target.get_hit_points()


func get_damage(_attack: float, _defense: float, hp: int) -> float:
	return hp
