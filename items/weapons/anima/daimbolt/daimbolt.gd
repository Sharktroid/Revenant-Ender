class_name Daimbolt
extends Anima


func _init() -> void:
	_heavy_weapon = true
	resource_name = "Daimbolt"
	_rank = Ranks.D
	_max_uses = 45
	_price = 47
	_might += 7
	_weight += 3
	_hit -= 5
	_max_range = 1 # Balanced out by Lightning Saint
	_flavor_text = "Casts down lightning that strikes twice."
	_description = "+1 primary and c.s. strike"
	super()