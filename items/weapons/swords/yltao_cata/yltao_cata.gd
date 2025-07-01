class_name YltaoCata
extends Sword


func _init() -> void:
	super()
	resource_name = "Yltao Cata"
	_rank = Ranks.S
	_max_uses = 42
	_price = 65
	_might += 12
	_weight += 5
	_hit += 15
	# TODO: Give a real name to the white dragon.
	_flavor_text = (
		'The white half of Krystaliythiyia\'s divine "Duality Blade". '
		+ "Imbued with the spirit of the fallen white dragon, it saps energy from its foes and heals its wielder with it."
	)
	_description = "Recovers 1 HP for every 2 damage dealt."
