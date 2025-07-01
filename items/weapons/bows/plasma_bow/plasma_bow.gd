class_name PlasmaBow
extends Bow


func _init() -> void:
	super()
	resource_name = "Plasma Bow"
	_rank = Ranks.S
	_max_uses = 20
	_price = 59
	_might += 13
	_weight += 3
	_hit += 5
	_crit = 5
	_flavor_text = "A bow that fires superheated arrows."
	_description = "Ignores blocking terrain. Targets resistance."
