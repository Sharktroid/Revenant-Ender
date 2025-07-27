class_name Bowgun
extends Bow


func _init() -> void:
	_preset = _Presets.IRON
	_heavy_weapon = true
	resource_name = "Bowgun"
	_flavor_text = "A basic bow that has its string released by a trigger."
	super()