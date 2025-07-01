class_name PolisSagittarii
extends Bow


func _init() -> void:
	super()
	resource_name = "Polis Sagittarii"
	_rank = Ranks.D
	_max_uses = 30
	_price = 56
	_might += 9
	_hit += 10
	_flavor_text = "A bow with the power of a class O star, that can also function as a tome."
	_description = "Pierce portion +1 primary and secondary strike."
