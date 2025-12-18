class_name Bane
extends CombatArt


func _init() -> void:
	_name = "Bane"


func get_damage(_attack: float, _defense: float, hp: int) -> float:
	return hp - 1
