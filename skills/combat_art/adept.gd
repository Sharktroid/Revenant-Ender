class_name Adept
extends StaticClass

class Alpha extends CombatArt:
	func _init() -> void:
		_name = "Adept α"
		_bonus_strikes = 1

class Omega extends Alpha:
	func _init() -> void:
		_name = "Adept ω"
