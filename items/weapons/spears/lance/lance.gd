class_name Lance
extends Spear


func _init() -> void:
	const LUCK_PENALTY = 15
	resource_name = "Lance"
	_rank = Ranks.B
	_max_uses = 40
	_price = 13
	_might += 17
	_weight += 4
	_hit += LUCK_PENALTY
	_flavor_text = "A cursed spear that drains the wielder's luck."
	_description = "-%s luck" % LUCK_PENALTY
	super()