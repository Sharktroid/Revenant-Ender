class_name FrozenBow
extends Bow


func _init() -> void:
	super()
	resource_name = "Frozen Bow"
	_rank = Ranks.A
	_max_uses = 20
	_price = 46
	_might += 9
	_weight += 3
	_hit -= 5
	_flavor_text = "A bow infused with ice-cold magic that stuns those who are hit."
	_description = "+0 magic damage. Solidifies on hit"