class_name Fire
extends Anima


func _init() -> void:
	super()
	_preset = _Presets.IRON
	resource_name = "Fire"
	_max_uses = 40
	_flavor_text = "Creates a scorching ball of fire."