class_name Crossbow
extends Bow


func _init() -> void:
	super()
	_preset = _Presets.BRONZE
	resource_name = "Crossbow"
	_flavor_text = "A mechanized bow thats string can be held and released with a trigger."