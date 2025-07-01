class_name HandAxe
extends Axe


func _init() -> void:
	super()
	resource_name = "Hand Axe"
	_rank = Ranks.C
	_max_uses = 20
	_price = 18
	_might -= 3
	_weight -= 2
	_hit -= 5
	_flavor_text = "An axe that can be thrown at range."