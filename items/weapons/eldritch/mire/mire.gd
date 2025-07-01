class_name Mire
extends Eldritch


func _init() -> void:
	super()
	resource_name = "Mire"
	_rank = Ranks.C
	_max_uses = 35
	_price = 15
	_might += 3
	_hit -= 10
	_max_range += 1
	_flavor_text = "Creates a ball of swampy mud and hurls it at foes."