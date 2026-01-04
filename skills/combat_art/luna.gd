class_name Luna
extends StaticClass

class Alpha extends CombatArt:
	func _init() -> void:
		_name = "Luna α"


	## Gets the defender's defense type against a weapon
	func get_defense(defense: int, _defender: Unit) -> int:
		return ceili(float(defense) / 2)


class Omega extends Alpha:
	func _init() -> void:
		_name = "Luna ω"


	## Gets the defender's defense type against a weapon
	func get_defense(_defense: int, _defender: Unit) -> int:
		return 0
