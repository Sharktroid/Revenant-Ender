class_name CleaveBow
extends Bow


func _init() -> void:
	resource_name = "Cleave Bow"
	_rank = Ranks.C
	_max_uses = 35
	_price = 25
	_might += 6
	_weight += 3
	_hit -= 10
	_effective_classes |= 1 << UnitClass.ArmorClasses.ARMOR
	_flavor_text = "A bow that fires arrows with long, thin, piercing arrowtips to penetrate armor."
	_description = "Effective against armors"
	super()