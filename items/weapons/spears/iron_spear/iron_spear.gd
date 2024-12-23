class_name IronSpear
extends Spear


# Weapon-specific variables.
func _init() -> void:
	resource_name = "Iron Spear"
	_rank = Ranks.D
	_hit = 95
	_might = 8
	_crit = 0
	_weight = 7
	_max_uses = 20
	_price = 2200
	_weapon_exp = 1
	_description = "A cheap, easy to wield spear."
#	effective_classes
	super()
