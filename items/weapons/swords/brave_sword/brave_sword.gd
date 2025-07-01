class_name BraveSword
extends Sword


func _init() -> void:
	super()
	_preset = _Presets.BRAVE
	_flavor_text = "A heavy yet deadly blade that strikes twice in a single attack."
	_description = "+1 primary strike and +1 c. s. strike."
