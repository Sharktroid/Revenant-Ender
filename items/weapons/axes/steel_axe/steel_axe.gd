class_name SteelAxe
extends Axe


# Weapon-specific variables.
func _init() -> void:
	resource_name = "Steel Axe"
	_rank = Ranks.B
	_hit = 90
	_might = 18
	_crit = 0
	_weight = 10
	_max_uses = 30
	_price = 1700
	_weapon_exp = 2
	_description = "A strong, quality axe."
	super()
