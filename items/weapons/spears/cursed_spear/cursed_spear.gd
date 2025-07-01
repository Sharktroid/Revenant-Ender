class_name CursedSpear
extends Spear


func _init() -> void:
	super()
	const LUCK_PENALTY = 15
	resource_name = "Cursed Spear"
	_rank = Ranks.D
	_max_uses = 40
	_price = 13
	_might += 17
	_weight += 4
	_hit += LUCK_PENALTY
	_flavor_text = "A cursed spear that drains the wielder's luck."
	_description = "-%s luck" % LUCK_PENALTY