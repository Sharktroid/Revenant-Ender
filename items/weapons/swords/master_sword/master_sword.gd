class_name MasterSword
extends Sword


func _init() -> void:
	super()
	_preset = _Presets.MASTER
	_hit += 10
	_crit = 20
	_flavor_text = "A beautiful sword covered in bands from the wootz steel that forged it."
	_description = "+1 primary strike."
