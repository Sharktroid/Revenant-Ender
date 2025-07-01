class_name CruiseSaunion
extends Spear


func _init() -> void:
	super()
	resource_name = "Cruise Saunion"
	_rank = Ranks.S
	_max_uses = 10
	_price = 65
	_might += 15
	_weight += 13
	_hit -= 10
	_min_range = 3
	_max_range = 6
	_flavor_text = "A spear with a rocket strapped to it, allowing it to travel great distances."
