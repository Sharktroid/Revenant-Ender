class_name Valmanwë
extends Sword


func _init() -> void:
	resource_name = "Valmanwë"
	_rank = Ranks.S
	_max_uses = 13
	_price = 56
	_might += 4
	_weight -= 1
	# TODO: Give this weapon's description real names for the merfolk and their kingdom.
	_flavor_text = "A legendary sword forged by the merfolk of the sea. Imbued with the raging power of a typhoon."
	_description = "+1x4 magic damage."
	super()
