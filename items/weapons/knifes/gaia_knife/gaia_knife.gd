class_name GaiaKnife
extends Knife


func _init() -> void:
	super()
	resource_name = "Gaia Knife"
	_rank = Ranks.A
	_max_uses = 20
	_price = 47
	_might += 6
	_weight += 3
	_hit -= 10
	_flavor_text = "A decorated knife with long golden lines. It is said to be blessed by the earth mother herself."
	_description = "Heals 1 HP per 2 dealt."