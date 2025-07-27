class_name Miasma
extends Eldritch


func _init() -> void:
	resource_name = "Miasma"
	_rank = Ranks.B
	_max_uses = 25
	_price = 37
	_might += 7
	_weight += 2
	_hit -= 5
	_flavor_text = "Summons a dark, filthy cloud to attack foes."
	_description = "Hits on the target's resistance."
	super()