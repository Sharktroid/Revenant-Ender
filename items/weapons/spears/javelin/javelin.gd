class_name Javelin
extends Spear


func _init() -> void:
	super()
	resource_name = "Javelin"
	_rank = Ranks.C
	_max_uses = 20
	_price = 22
	_might += 7 - 10
	_weight += 13 - 10
	_hit += 70 - 85
	_min_range = 1
	_max_range = 2
	_flavor_text = "A spear designed to be thrown."