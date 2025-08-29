class_name Glaive
extends Spear


func _init() -> void:
	resource_name = "Glaive"
	_rank = Ranks.C
	_max_uses = 35
	_price = 24
	_might += 4
	_weight += 1
	_hit -= 5
	_effective_classes |= 1 << UnitClass.ArmorClasses.CAVALRY
	_flavor_text = "A long polearm with a curved blade for wounding riders."
	_description = "Effective against cavalry units."
	super()