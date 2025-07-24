class_name PolisSagittarii
extends Bow


func _init() -> void:
	super()
	resource_name = "Polis Sagittarii"
	_mode_name = "Bow"
	_rank = Ranks.D
	_max_uses = 30
	_price = 56
	_might += 9
	_hit += 10
	_flavor_text = "A bow infused with the power of a class O star."
	_description = "+1 primary and secondary strike."
	_linked_weapon = _clone()
	_linked_weapon._damage_type = DamageTypes.MAGICAL
	_linked_weapon._mode_name = "Cast"
	_linked_weapon._min_range = 1
	_linked_weapon._max_range = 2
