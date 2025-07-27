class_name SwordOfDawn
extends Sword


func _init() -> void:
	resource_name = "Sword of Dawn"
	_rank = Ranks.B
	_max_uses = 20
	_price = 41
	_might += 3
	_weight += 7
	_hit -= 25
	_flavor_text = "A sword that can summon warriors from beyond the grave."
	_description = "Can summon four bonewalkers for 5 durability."
	super()
