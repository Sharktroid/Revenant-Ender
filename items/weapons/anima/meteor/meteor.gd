class_name Meteor
extends Anima


func _init() -> void:
	super()
	_heavy_weapon = true
	resource_name = "Meteor"
	_rank = Ranks.S
	_max_uses = 5
	_price = 150
	_might += 9
	_weight += 5
	_hit -= 15
	_min_range = 3
	_max_range = 7
	_flavor_text = "De-orbits a small asteroid from space and generates a massive impact on its foes."
	_description = "Deals splash damage to anyone adjacent to target."