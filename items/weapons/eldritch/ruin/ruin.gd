class_name Ruin
extends Eldritch


func _init() -> void:
	resource_name = "Ruin"
	_rank = Ranks.B
	_max_uses = 20
	_price = 34
	_might += 3
	_weight += 3
	_hit -= 5
	_crit = INF
	_flavor_text = "Sends a life-killing burst of energy at an enemy."
	super()