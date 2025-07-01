class_name Purge
extends Holy


func _init() -> void:
	super()
	resource_name = "Purge"
	_rank = Ranks.D
	_max_uses = 5
	_price = 150
	_might += 5
	_min_range = 3
	_max_range = 7
	_flavor_text = "Hurls light beams at distant foes."
