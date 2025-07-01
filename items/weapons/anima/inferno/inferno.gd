class_name Inferno
extends Anima


func _init() -> void:
	super()
	resource_name = "Inferno"
	_rank = Ranks.C
	_max_uses = 35
	_price = 26
	_might += 3
	_weight += 3
	_hit -= 10
	_flavor_text = "Brings forth a roaring inferno that melts anything in its wake."
	_description = "Effective against armored units"