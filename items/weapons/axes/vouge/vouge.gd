class_name Vouge
extends Axe


func _init() -> void:
	resource_name = "Vouge"
	_rank = Ranks.B
	_max_uses = 60
	_price = 36
	_might += 3
	_weight += 1
	_hit += 5
	_crit = 25
	_max_range = 2
	_flavor_text = "A deadly axe that can be thrown with deadly accuracy."
	super()