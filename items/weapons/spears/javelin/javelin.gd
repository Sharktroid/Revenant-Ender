class_name Javelin
extends Spear


func _init() -> void:
	super()
	resource_name = "Javelin"
	_mode_name = "Melee"
	_rank = Ranks.C
	_max_uses = 20
	_price = 22
	_might -= 3
	_weight -= 3
	_hit -= 10
	_flavor_text = "A spear designed to be thrown."
	_linked_weapon = _clone()
	_linked_weapon._damage_type = DamageTypes.RANGED
	_linked_weapon._mode_name = "Throw"
	_linked_weapon._max_range = 2
