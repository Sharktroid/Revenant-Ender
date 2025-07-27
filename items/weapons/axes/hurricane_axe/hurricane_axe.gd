class_name HurricaneAxe
extends Axe


func _init() -> void:
	resource_name = "Hurricane Axe"
	_rank = Ranks.A
	_mode_name = "Melee"
	_max_uses = 30
	_price = 47
	_might += 7
	_weight += 4
	_hit -= 5
	_flavor_text = "An axe that can unleash the fury of a storm upon its enemies."
	_linked_weapon = HurricaneAxeCast.new()
	super()

class HurricaneAxeCast extends Anima:
	func _init() -> void:
		super()
		_heavy_weapon = true
		_mode_name = "Cast"
		_might += 12
		_weight += 2
		_hit -= 5