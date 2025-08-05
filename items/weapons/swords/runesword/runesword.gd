class_name Runesword
extends Sword


func _init() -> void:
	resource_name = "Runesword"
	_rank = Ranks.A
	_damage_type = DamageTypes.MAGICAL
	_max_uses = 15
	_price = 48
	_might += 10
	_weight += 4
	_hit -= 5
	_min_range = 1
	_max_range = 2
	_flavor_text = "A sword with ancient runes inscribed on it."
	_description = "Recovers 1 hp per 2 dealt."
	super()
