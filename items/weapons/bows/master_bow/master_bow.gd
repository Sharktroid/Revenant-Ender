class_name MasterBow
extends Bow


func _init() -> void:
	super()
	_preset = _Presets.MASTER
	_weight += 2
	_hit += 20
