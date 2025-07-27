class_name Ginnungagap
extends Eldritch


func _init() -> void:
	resource_name = "Ginnungagap"
	_rank = Ranks.A
	_max_uses = 25
	_price = 47
	_might += 25
	_weight += 5
	_hit += 20
	_flavor_text = "Surrounds the target with a consuming void that puts a burden on the wielder."
	_description = "Inflicts Cripple on wielder."
	super()