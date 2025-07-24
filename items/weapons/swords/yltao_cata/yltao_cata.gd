class_name YltaoCata
extends Sword

func _init() -> void:
	super()
	_heavy_weapon = true
	_mode_name = "Melee"
	resource_name = "Yltao Cata"
	_rank = Ranks.S
	_max_uses = 42
	_price = 65
	_might += 8
	_weight += 1
	_hit += 15
	# TODO: Give a real name to the white dragon.
	_flavor_text = (
		'The white half of Krystaliythiyia\'s divine "Duality Blade". '
		+ "Imbued with the spirit of the fallen white dragon, it saps energy from its foes and heals its wielder with it."
	)
	_description = "Recovers 1 HP for every 2 damage dealt."
	_linked_weapon = _clone()
	_linked_weapon._damage_type = DamageTypes.MAGICAL
	_linked_weapon._mode_name = "Cast"
	_linked_weapon._max_range = 2
	_linked_weapon._heavy_weapon = false

