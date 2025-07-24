class_name Gungnir
extends Spear


func _init() -> void:
	super()
	resource_name = "Gungnir"
	_mode_name = "Melee"
	_rank = Ranks.S
	_max_uses = 45
	_price = 58
	_might += 15
	_weight += 3
	_hit = INF
	_min_range = 1
	_flavor_text = "A spear said to be forged by a thunderbolt. It never misses its target."
	_linked_weapon = _clone()
	_linked_weapon._damage_type = DamageTypes.RANGED
	_linked_weapon._mode_name = "Throw"
	_linked_weapon._max_range = 2