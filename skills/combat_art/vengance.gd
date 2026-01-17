class_name Vengance
extends CombatArt


func _init() -> void:
	_name = "Vengance"


## Gets the defender's defense type against a weapon
func get_attack(attacker: Unit) -> int:
	return super(attacker) + floori(roundf(attacker.get_hit_points() - attacker.current_health) / 3)
