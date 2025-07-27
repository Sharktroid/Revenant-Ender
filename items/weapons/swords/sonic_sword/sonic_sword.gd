class_name SonicSword
extends Sword


func _init() -> void:
	resource_name = "Sonic Sword"
	_rank = Ranks.B
	_max_uses = 10
	_price = 46
	_might += 6
	_weight -= 2
	_hit += 20
	_flavor_text = "A sword that delivers a lightning-fast strike that staggers foes."
	_description = "Solidifies the target on hit."
	super()
