class_name AllOutAssault
extends CombatArt


func _init() -> void:
	_name = "All-Out Assault"
	_bonus_strikes = 2


func get_crit_rate(crit: int, strike: int) -> int:
	if strike == 2:
		return 100
	return super(crit, strike)
