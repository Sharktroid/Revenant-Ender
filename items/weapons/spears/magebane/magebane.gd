class_name Magebane
extends Spear


func _init() -> void:
	resource_name = "Magebane"
	_rank = Ranks.B
	_max_uses = 30
	_price = 34
	_might += 10
	_weight += 2
	_hit -= 5
	_max_range = 2
	_flavor_text = "A spear that is designed to slay magic users."
	_description = "Effective against mages."
	super()