class_name HurricaneAxe
extends Axe


func _init() -> void:
	super()
	resource_name = "Hurricane Axe"
	_rank = Ranks.A
	_max_uses = 30
	_price = 47
	_might += 18
	_weight += 6
	_hit -= 5
	_max_range = 2
	_damage_type = DamageTypes.MAGICAL
	_flavor_text = "An axe that can unleash the fury of a storm upon its enemies."
	_description = "Deals magical damage."