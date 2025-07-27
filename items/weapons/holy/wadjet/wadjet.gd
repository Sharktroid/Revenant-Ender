class_name Wadjet
extends Holy


func _init() -> void:
	resource_name = "Wadjet"
	_rank = Ranks.S
	_max_uses = 15
	_price = 62
	_might += 10
	_weight += 3
	_hit -= 5
	_flavor_text = "Summons the guardian goddess Wadjet to elimitate foes and protect the user."
	_description = "Halves damage taken."
	super()