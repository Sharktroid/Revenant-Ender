class_name Mjölnir
extends Axe


func _init() -> void:
	resource_name = "Mjölnir"
	_rank = Ranks.D
	_max_uses = 20
	_price = 53
	_might += 12
	_weight += 3
	_hit += 10
	_max_range = 2
	_flavor_text = "A hammer made by Irashkalla for Adriana as a gift. It is based on Gurthang, with similar lightning magic and accuracy."
	_description = "+10 skill. +6 magic damage."
	super()