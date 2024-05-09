class_name SteelAxe
extends Axe


# Weapon-specific variables.
func _init() -> void:
	resource_name = "Steel Axe"
	_rank = Ranks.D
	_might = 13
	_weight = 15
	_hit = 55
	_crit = 0
	_max_uses = 25
	_price = 1700
	_weapon_exp = 2
	_description = "A strong, quality axe."
	super()
