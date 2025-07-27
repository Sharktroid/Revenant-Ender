class_name Sylphid
extends Anima


func _init() -> void:
	resource_name = "Sylphid"
	_rank = Ranks.D
	_max_uses = 6
	_price = 46
	_might += 7
	_weight += 1
	_hit += 10
	_flavor_text = "Summons the saint of the wind to blow a chilling gale at foes."
	_description = "Solidifies on hit."
	super()