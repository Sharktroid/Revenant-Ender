class_name GaleBlade
extends Sword


func _init() -> void:
	super()
	resource_name = "Gale Blade"
	_rank = Ranks.B
	_max_uses = 40
	_price = 39
	_might += 5
	_weight += 1
	_hit += 15
	_crit = 5
	_flavor_text = "A sword imbued with wind magic. It can create gales that wreak terror on flying foes."
	_description = "Effective against fliers. Falcon Knights only."
