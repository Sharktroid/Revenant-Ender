class_name Armorslayer
extends Sword


func _init() -> void:
	super()
	resource_name = "Armorslayer"
	_rank = Ranks.C
	_max_uses = 20
	_price = 30
	_might += 2
	_weight += 1
	_flavor_text = "A slender blade designed to pierce through armor."
	_description = "Halves the target's defense."
