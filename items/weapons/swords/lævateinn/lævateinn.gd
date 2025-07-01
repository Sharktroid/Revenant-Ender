class_name Lævateinn
extends Sword


func _init() -> void:
	super()
	resource_name = "Lævateinn"
	_rank = Ranks.S
	_max_uses = 30
	_price = 52
	_might += 21 - 6
	_weight += 10 - 6
	_hit += 90 - 100
	_flavor_text = "An ornate sword infused with fire magic that can create roaring infernos in the blink of an eye."
	_description = "+5 magic, +5 resistance."
