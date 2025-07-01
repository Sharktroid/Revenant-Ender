class_name Mercurius
extends Sword


func _init() -> void:
	super()
	resource_name = "Mercurius"
	_rank = Ranks.S
	_max_uses = 20
	_price = 56
	_might += 18
	_weight += 2
	_flavor_text = "A legendary sword from the age of Krystaliythiyia."
	_description = "Boosts the wielder's learning rate.\n\nx2 EV gain."
