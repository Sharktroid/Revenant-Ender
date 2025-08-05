class_name HeroicSpear
extends Spear


func _init() -> void:
	_preset = _Presets.BRAVE
	resource_name = "Heroic Spear"
	_flavor_text = "A heavy yet deadly spear that deals massive damage on initiation."
	_might += _get_preset_might(_Presets.SILVER) - _get_preset_might(_Presets.BRAVE)
	super()


func get_might() -> float:
	return super() - 6


func get_initial_might() -> float:
	return super() + 6
