class_name Pilum
extends Spear


func _init() -> void:
	resource_name = "Pilum"
	_mode_name = "Melee"
	_rank = Ranks.B
	_max_uses = 20
	_price = 42
	_might += 7
	_weight += 2
	_hit -= 5
	_flavor_text = "A powerful spear that can be thrown at enemies to deal damage from a distance."
	_linked_weapon = _clone()
	_linked_weapon._damage_type = DamageTypes.RANGED
	_linked_weapon._mode_name = "Thrown"
	_linked_weapon._max_range = 2
	super()
