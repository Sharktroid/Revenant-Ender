class_name IronAxe
extends Axe


# Weapon-specific variables.
func _init() -> void:
	resource_name = "Iron Axe"
	_rank = Ranks.D
	_hit = 90
	_might = 10
	_crit = 0
	_weight = 8
	_max_uses = 20
	_price = 1100
	_weapon_exp = 1
	_description = "A cheap, easy to wield axe."
	super()
