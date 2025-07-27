class_name SubmachineBow
extends Bow


func _init() -> void:
	_heavy_weapon = true
	resource_name = "Submachine Bow"
	_rank = Ranks.S
	_max_uses = 40
	_price = 54
	_might = 0
	_weight += 3
	_hit -= 10
	_flavor_text = "A bow with a revolving barrel that fires arrows at an incredible rate."
	_description += "+7 primary and c.s. strikes."
	super()
