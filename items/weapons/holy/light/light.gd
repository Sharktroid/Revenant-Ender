class_name Light
extends Holy


func _init() -> void:
	super()
	_preset = _Presets.IRON
	resource_name = "Light"
	_flavor_text = "Sends a ray of light to hurt opponents."