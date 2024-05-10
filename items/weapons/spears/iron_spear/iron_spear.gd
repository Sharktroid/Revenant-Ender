class_name IronSpear
extends Spear


# Weapon-specific variables.
func _init() -> void:
	resource_name = "Iron Spear"
	_rank = Ranks.D
	_might = 7
	_weight = 9
	_hit = 70
	_crit = 0
	_max_uses = 40
	_price = 2200
	_weapon_exp = 1
	_description = "A cheap, easy to wield spear."
#	effective_classes
	super()
