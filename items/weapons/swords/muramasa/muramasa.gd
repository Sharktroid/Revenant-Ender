class_name Muramasa
extends Sword


func _init() -> void:
	resource_name = "Muramasa"
	_rank = Ranks.D  #Prf
	_max_uses = 66
	_price = 33
	_might += 9
	_weight += 3  #"How much weight can you handle?"
	_hit -= 13
	_flavor_text = "A cursed blade that is said to have a mind of its own that thirsts for blood."
	_description = "+2 might for every enemy defeated with it. Boost fades by 1 per turn and resets upon the end of the chapter."
	super()
