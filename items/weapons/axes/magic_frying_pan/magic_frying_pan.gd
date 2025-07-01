class_name MagicFryingPan
extends Axe


func _init() -> void:
	super()
	const LUCK_MODIFIER: int = 15
	resource_name = "Angelic Frying Pan"
	_rank = Ranks.A
	_max_uses = 35
	_price = 48
	_might += 6
	_weight += 2
	_hit -= 15 + LUCK_MODIFIER
	_crit = 25
	_description = "A frying pan blessed with a holy aura that boosts the wielder's aura."
	_flavor_text = "+5 magic, +15 luck."