class_name Saunion
extends Spear


func _init() -> void:
	resource_name = "Saunion"
	_damage_type = DamageTypes.RANGED
	_rank = Ranks.B
	_max_uses = 30
	_price = 37
	_might += 7
	_min_range = 2
	_max_range = 3
	_flavor_text = "A spear that can be thrown at enemies to deal damage from a distance, but can't be used in close combat."
	super()