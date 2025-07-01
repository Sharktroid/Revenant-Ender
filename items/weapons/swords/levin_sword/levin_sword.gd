class_name LevinSword
extends Sword


func _init() -> void:
	super()
	resource_name = "Levin Sword"
	_rank = Ranks.B
	_max_uses = 25
	_price = 36
	_might += 10
	_weight += 1
	_hit -= 5
	_flavor_text = "A sword that can channel electricity, sending bolts of lightning at foes."
