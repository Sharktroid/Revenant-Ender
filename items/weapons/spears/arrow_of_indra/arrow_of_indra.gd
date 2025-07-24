class_name ArrowOfIndra
extends Spear


func _init() -> void:
	super()
	resource_name = "Arrow of Indra"
	_mode_name = "Melee"
	_rank = Ranks.A
	_max_uses = 30
	_price = 46
	_might += 12
	_hit += 5
	_min_range = 1
	_max_range = 2
	_description = "A shimmering magical spear that can harness the power of lightning."
	_linked_weapon = _clone()
	_linked_weapon._damage_type = DamageTypes.MAGICAL
	_linked_weapon._mode_name = "Cast"
	_linked_weapon._max_range = 2
