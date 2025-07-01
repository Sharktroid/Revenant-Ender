class_name ShadowSword
extends Sword


func _init() -> void:
	super()
	resource_name = "Shadow Sword"
	_rank = Ranks.D
	_max_uses = 66
	_price = 13
	_might += 15
	_weight += 1
	_hit -= 20
	_flavor_text = "A sword forged from the essence of darkness."
	_description = "Deals 1 recoil per 2 dealt."
