class_name RepeatingCrossbow
extends Bow


func _init() -> void:
	super()
	_heavy_weapon = true
	resource_name = "Repeating Crossbow"
	_rank = Ranks.B
	_max_uses = 20
	_price = 38
	_might-=_HEAVY_MIGHT_MODIFIER
	_weight += 1
	_hit -= 5
	_max_range = 2
	_flavor_text = "A crossbow that fires many bolts in fast succession."
	_description = "+3 primary and c.s. strikes."
