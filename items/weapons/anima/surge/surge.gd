class_name Surge
extends Anima


func _init() -> void:
	resource_name = "Surge"
	_rank = Ranks.C
	_max_uses = 35
	_price = 22
	_might += 7
	_weight -= 1
	_hit = INF
	_max_range = 1
	_flavor_text = "Sends a burst of electricity through the ground."
	super()