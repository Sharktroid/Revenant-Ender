class_name Rapier
extends Sword


func _init() -> void:
	resource_name = "Rapier"
	_rank = Ranks.B
	_max_uses = 30
	_price = 33
	_might += 6
	_weight -= 2
	_hit += 10
	_flavor_text = "A thin, pointed sword designed for thrusting attacks."
	_description = "Ignores shields."
	super()
