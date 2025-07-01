class_name Tomahawk
extends Axe


func _init() -> void:
	super()
	resource_name = "Tomahawk"
	_rank = Ranks.A
	_max_uses = 20
	_price = 47
	_might += 4
	_max_range = 2
	_flavor_text = "A finely crafted throwing axe."