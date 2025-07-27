class_name Longbow
extends Bow


func _init() -> void:
	resource_name = "Longbow"
	_rank = Ranks.B
	_max_uses = 25
	_price = 32
	_might += 5
	_weight += 4
	_hit -= 10
	_min_range = 2
	_max_range = 5
	_flavor_text = "A long bow that can stretch extra far, letting it fire arrows from long range."
	super()