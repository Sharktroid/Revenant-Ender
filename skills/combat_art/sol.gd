class_name Sol
extends CombatArt
func _init() -> void:
	_name = "Sol"


func get_attack_queue(combat: Combat) -> Array[CombatStage]:
	return [SolStage.new(combat, true, true, true)]


class SolStage:
	extends CombatStage

	func get_recoil() -> float:
		return floorf((get_attacker().get_weapon().get_recoil_multiplier() - 0.5) * get_damage())
