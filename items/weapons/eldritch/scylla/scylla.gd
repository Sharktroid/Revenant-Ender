class_name Scylla
extends Eldritch


func _init() -> void:
	super()
	resource_name = "Scylla"
	_rank = Ranks.C
	_max_uses = 25
	_price = 22
	_weight += 1
	_hit += 5
	_flavor_text = "Summons a sea serpent to attack an opponent."
	_description = "Halves the target's current HP, rounded down."