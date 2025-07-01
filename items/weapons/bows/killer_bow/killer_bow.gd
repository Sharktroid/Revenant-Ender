class_name KillerBow
extends Bow


func _init() -> void:
	super()
	_preset = _Presets.KILLER
	_heavy_weapon = true
	_flavor_text = "A crossbow that stores immense tension, making it more likely to land a critical hit."