class_name Grafcalibur
extends Anima


func _init() -> void:
	resource_name = "Grafcalibur"
	_rank = Ranks.D
	_max_uses = 11
	_price = 45
	_might += 6
	_hit += 15
	_crit = 40
	_effective_classes |= 1 << UnitClass.ArmorClasses.FLIER
	_flavor_text = "A familiar tome that sends gusts that fly through the skies, cutting up anything in its way."
	_description = "Grants Pursuit. Effective against fliers."
	super()
