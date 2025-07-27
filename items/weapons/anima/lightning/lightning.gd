class_name Lightning
extends Anima


func _init() -> void:
	_heavy_weapon = true
	resource_name = "Lightning"
	_rank = Ranks.D
	_max_uses = 35
	_price = 15
	_might -= 2
	_weight += 2
	_hit -= 5
	_max_range += 1
	_flavor_text = "Casts a bolt of lightning down upon its foes."
	super()
