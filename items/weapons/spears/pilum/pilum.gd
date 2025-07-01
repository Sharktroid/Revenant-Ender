class_name Pilum
extends Spear


func _init() -> void:
	super()
	resource_name = "Pilum"
	_rank = Ranks.B
	_max_uses = 20
	_price = 42
	_might += 7
	_weight += 2
	_hit -= 5
	_min_range = 1
	_max_range = 2
	_flavor_text = "A powerful spear that can be thrown at enemies to deal damage from a distance."