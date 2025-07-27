class_name Bolting
extends Anima


func _init() -> void:
	resource_name = "Bolting"
	_rank = Ranks.B
	_max_uses = 5
	_price = 100
	_might += 5
	_weight += 5
	_hit -= 10
	_min_range = 3
	_max_range = 7
	_flavor_text = "Causes a bolt of lightning to crash down upon an opponent from a long distance."
	super()