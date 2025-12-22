class_name Lunge
extends CombatArt

func _init() -> void:
	_name = "Lunge"


func finish(attacker: Unit, defender: Unit) -> void:
	var attacker_position: Vector2 = attacker.position
	attacker.position = defender.position
	defender.position = attacker_position
