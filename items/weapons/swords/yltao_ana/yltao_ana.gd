class_name YltaoAna
extends Sword


func _init() -> void:
	resource_name = "Yltao Ana"
	_mode_name = "Melee"
	_rank = Ranks.S
	_max_uses = 42
	_price = 65
	_might += 11
	_weight += 1
	_hit += 15
	# TODO: Give a real name to the black dragon.
	_flavor_text = (
		'The black half of Krystaliythiyia\'s divine "Duality Blade". '
		+ "Imbued with the spirit of the fallen black dragon, it can cut through anything."
	)
	_description = "Ignores enemy defense."
	_linked_weapon = _clone()
	_linked_weapon._damage_type = DamageTypes.MAGICAL
	_linked_weapon._mode_name = "Cast"
	_linked_weapon._max_range = 2
	_linked_weapon._description = "Ignores enemy resistance."
	_linked_weapon._heavy_weapon = true
	super()