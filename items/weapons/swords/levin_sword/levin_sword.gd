class_name LevinSword
extends Sword


func _init() -> void:
	resource_name = "Levin Sword"
	_mode_name = "Melee"
	_rank = Ranks.B
	_max_uses = 25
	_price = 36
	_might += 10
	_weight += 1
	_hit -= 5
	_flavor_text = "A sword that can channel electricity, sending bolts of lightning at foes."
	_linked_weapon = _clone()
	_linked_weapon._damage_type = DamageTypes.MAGICAL
	_linked_weapon._mode_name = "Cast"
	_linked_weapon._max_range = 2
	super()