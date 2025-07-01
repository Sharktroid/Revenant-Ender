class_name SwordOfSlumber
extends Sword


func _init() -> void:
	super()
	_preset = _Presets.STATUS
	resource_name = "Sword of Slumber"
	_rank = Ranks.A
	_flavor_text = "A sword coated in a sleep-inducing poison."
	_description = "Causes the target to fall asleep on hit. Will end combat on hit."
