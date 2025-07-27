class_name Sagittae
extends Holy


func _init() -> void:
	resource_name = "Sagittae"
	_rank = Ranks.B
	_max_uses = 25
	_price = 37
	_might += 6
	_hit += 5
	_flavor_text = "Summons a storm of light arrows to barrage foes."
	_description = "Hits on pierce."
	super()