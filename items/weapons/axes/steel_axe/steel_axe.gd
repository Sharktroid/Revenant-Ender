class_name SteelAxe
extends Axe


# Weapon-specific variables.
func _init() -> void:
	resource_name = "Steel Axe"
	_rank = Ranks.B
	_might = 13
	_weight = 15
	_hit = 75
	_crit = 0
	_max_uses = 35
	_price = 1700
	_weapon_exp = 2
	_description = "A strong, quality axe."
	super()
