class_name Zantetsuken
extends Sword


func _init() -> void:
	super()
	resource_name = "Zantetsuken"
	_rank = Ranks.D
	_max_uses = 60
	_price = 29
	_might += 12
	_weight += 2
	_hit -= 10
	_flavor_text = '"Legendary" iron-cutting sword.'
	_description = "Effective against armored units."
