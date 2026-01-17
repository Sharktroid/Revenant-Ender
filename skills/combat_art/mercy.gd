class_name Mercy
extends CombatArt


func _init() -> void:
	_name = "Mercy"


func get_damage(attack: float, defense: float, hp: int) -> float:
	return minf(hp - 1, super(attack, defense, hp))
