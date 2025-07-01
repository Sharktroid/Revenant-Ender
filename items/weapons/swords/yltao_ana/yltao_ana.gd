class_name YltaoAna
extends Sword


func _init() -> void:
	super()
	resource_name = "Yltao Ana"
	_rank = Ranks.S
	_max_uses = 42
	_price = 65
	_might += 17
	_weight += 5
	_hit += 15
	# TODO: Give a real name to the black dragon.
	_flavor_text = (
		'The black half of Krystaliythiyia\'s divine "Duality Blade". '
		+ "Imbued with the spirit of the fallen black dragon, it can cut through anything."
	)
	_description = "Ignores enemy defense."
