class_name Dolharken
extends Axe


func _init() -> void:
	super()
	resource_name = "Dolharken"
	_rank = Ranks.D
	_max_uses = 50
	_price = 32
	_might += 13
	_weight += 7
	_hit -= 15
	_flavor_text = "A heavy and inaccurate axe that reduces the damage taken by its wielder."
	_description = "Halves the damage taken by the wielder."