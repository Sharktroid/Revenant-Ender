class_name Luna
extends CombatArt


func _init() -> void:
	_name = "Luna"


## Gets the defender's defense type against a weapon
func get_defense(_attacker: Unit, _defender: Unit) -> int:
	return 0
