class_name Luna
extends StaticClass

class Alpha extends CombatArt:
	func _init() -> void:
		_name = "Luna α"


	## Gets the defender's defense type against a weapon
	func get_defense(attacker: Unit, defender: Unit) -> int:
		return ceili(float(super(attacker, defender)) / 2)


class Omega extends Alpha:
	func _init() -> void:
		_name = "Luna ω"


	## Gets the defender's defense type against a weapon
	func get_defense(_attacker: Unit, _defender: Unit) -> int:
		return 0
