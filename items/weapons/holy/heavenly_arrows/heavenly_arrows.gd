class_name HeavenlyArrows
extends Holy


func _init() -> void:
	resource_name = "Heavenly Arrows"
	_rank = Ranks.A
	_max_uses = 5
	_price = 125
	_weight += 5
	_hit -= 20
	_min_range = 3
	_max_range = 7
	_flavor_text = "Casts judgement on foes by hurling divine bolts on foes."
	_description = "Ignores target's resistance. Wielder's int is halved for damage calculations."
	super()
