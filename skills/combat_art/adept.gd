class_name Adept
extends CombatArt


func _init() -> void:
	_name = "Adept"
	_additional_primary_strikes = 1


func is_active(unit: Unit, target: Unit) -> bool:
	return unit.get_attack_speed() >= target.get_attack_speed()
