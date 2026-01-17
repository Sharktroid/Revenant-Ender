class_name Hexblade
extends CombatArt


func _init() -> void:
	_name = "Hexblade"


func get_attack(unit: Unit) -> int:
	return unit.get_intelligence()


func get_defense(_base_defense: int, defender: Unit) -> int:
	return defender.get_resistance()
