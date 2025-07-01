class_name Wingclipper
extends Sword


func _init() -> void:
	super()
	resource_name = "Wingclipper"
	_rank = Ranks.C
	_max_uses = 28
	_price = 23
	_might += 5
	_weight += 2
	_hit += 5
	_flavor_text = "A sword with a slightly curved blade, meant to clip the wings of flying enemies."
	_description = "Effective against fliers."
