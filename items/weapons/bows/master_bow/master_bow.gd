class_name MasterBow
extends Bow


func _init() -> void:
	_preset = _Presets.MASTER
	_weight += 2
	_hit += 20
	super()
