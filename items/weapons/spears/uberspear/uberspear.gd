class_name Uberspear
extends Spear


func _init() -> void:
	super()
	resource_name = "Uberspear"
	_rank = Ranks.S
	_max_uses = 5
	_price = 500
	_might += 30
	_hit = INF - 85
	_crit = INF
	_min_range = 1
	_max_range = 3
	_flavor_text = "A spear infused with a power that vastly increases the strength of its wielder."
	_description = "Maxes all stats of the wielder."