class_name Blizzard
extends Anima


func _init() -> void:
	super()
	_preset = _Presets.BRONZE
	resource_name = "Blizzard"
	_rank = Ranks.C
	_max_uses = 30
	_flavor_text = "Surrounds its foes in a chilling ice storm."