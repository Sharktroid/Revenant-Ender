class_name GaleBlade
extends Sword


func _init() -> void:
	super()
	resource_name = "Gale Blade"
	_mode_name = "Melee"
	_rank = Ranks.B
	_max_uses = 40
	_price = 39
	_might += 5
	_weight += 1
	_hit += 15
	_crit = 5
	_flavor_text = "A sword imbued with wind magic. It can create gales that wreak terror on flying foes.\nFalcon Knights only."
	_linked_weapon = _clone()
	_linked_weapon._damage_type = DamageTypes.MAGICAL
	_linked_weapon._mode_name = "Cast"
	_linked_weapon._max_range = 2
