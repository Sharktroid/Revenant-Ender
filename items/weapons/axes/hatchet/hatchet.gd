class_name Hatchet
extends Axe


func _init() -> void:
	super()
	_preset = _Presets.SLIM
	resource_name = "Hatchet"
	_might -= 1
	_max_range = 2
	_flavor_text = "A small axe that can be thrown at range."