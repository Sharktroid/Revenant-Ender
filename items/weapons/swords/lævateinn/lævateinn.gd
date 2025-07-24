class_name Lævateinn
extends Sword

const DESCRIPTION: String = "+5 magic, +5 resistance."

func _init() -> void:
	super()
	resource_name = "Lævateinn"
	_rank = Ranks.S
	_mode_name = "Melee"
	_max_uses = 30
	_price = 52
	_might += 8
	_weight += 2
	_hit -= 10
	_flavor_text = "An ornate sword infused with fire magic that can create roaring infernos in the blink of an eye."
	_description = DESCRIPTION
	_linked_weapon = LævateinnCast.new()

class LævateinnCast extends Anima:
	func _init() -> void:
		super()
		_heavy_weapon = true
		resource_name = "Lævateinn"
		_mode_name = "Cast"
		_might += 14
		_weight += 2
		_hit -= 10
		_description = DESCRIPTION