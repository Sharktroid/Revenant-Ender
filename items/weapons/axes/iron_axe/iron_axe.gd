class_name IronAxe
extends Axe


# Weapon-specific variables.
func _init() -> void:
	resource_name = "Iron Axe"
	_rank = Ranks.D
	_might = 9
	_weight = 10
	_hit = 65
	_crit = 0
	_max_uses = 30
	_price = 1100
	_weapon_exp = 1
	_description = "A cheap, easy to wield axe."
	super()
