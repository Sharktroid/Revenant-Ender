class_name CuttingGale
extends Anima


func _init() -> void:
	resource_name = "Cutting Gale"
	_rank = Ranks.C
	_max_uses = 30
	_price = 23
	_might += 3
	_weight += 1
	_hit += 10
	_effective_classes |= 1 << UnitClass.ArmorClasses.FLIER
	_flavor_text = "Summons a fast, fierce gust of wind."
	_description = "Effective against fliers."
	super()
