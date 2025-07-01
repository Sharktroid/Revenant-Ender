class_name BallLightning
extends Anima


func _init() -> void:
	super()
	resource_name = "Ball Lightning"
	_rank = Ranks.B
	_max_uses = 25
	_price = 34
	_might += 13
	_weight -= 1
	_hit += 10
	_min_range = 2
	_flavor_text = "Summons an eerie ball of electricity."