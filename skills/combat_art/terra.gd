class_name Terra
extends CombatArt


func _init() -> void:
	_name = "Terra"


func get_damage(attack: float, defense: float, _hp: int) -> float:
	return super(attack, defense, _hp) * 2
