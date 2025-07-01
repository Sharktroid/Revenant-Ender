class_name Zanbato
extends Sword


func _init() -> void:
	super()
	resource_name = "Zanbato"
	_rank = Ranks.D
	_max_uses = 60
	_price = 28
	_might += 10
	_weight += 7
	_flavor_text = '"Legendary" sword with a wide blade, used to cut through a rider and their mount.'
	_description = "Effective against cavalry."
