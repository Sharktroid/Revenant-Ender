class_name Javelin
extends Spear


# Weapon-specific variables.
func _init() -> void:
	resource_name = "Javelin"
	_rank = Ranks.C
	_might = 6
	_weight = 12
	_hit = 50
	_crit = 0
	_max_uses = 20
	_price = 1200
	_weapon_exp = 1
	_description = "A throwing spear that can also\nattack from range"
	super()
	_max_range = 2

