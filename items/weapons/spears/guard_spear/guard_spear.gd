class_name GuardSpear
extends Spear


func _init() -> void:
	resource_name = "Guard Spear"
	_rank = Ranks.B
	_max_uses = 20
	_price = 33
	_might += 4
	_weight -= 2
	_hit -= 10
	_flavor_text = "A spear that bolsters the user's defenses."
	_description = "+4 defense and armor"
	super()