class_name Stormbringer
extends Sword


func _init() -> void:
	super()
	resource_name = "Stormbringer"
	_rank = Ranks.A
	_max_uses = 25
	_price = 37
	_might += 10
	_weight += 6
	_hit -= 15
	_flavor_text = "A sword said to have a will of its own."
	_description = "Grants Lifetaker."
