class_name Hel
extends Eldritch


func _init() -> void:
	super()
	resource_name = "Hel"
	_rank = Ranks.A
	_max_uses = 15
	_price = 37
	_weight += 5
	_hit -= 5
	_flavor_text = "Blasts the chilling winds of the underworld at foes."
	_description = "Sets the target's HP to 1. Won't counter if target is already at 1 HP."