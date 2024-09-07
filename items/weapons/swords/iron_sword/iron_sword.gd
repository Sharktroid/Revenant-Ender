class_name IronSword
extends Sword


# Weapon-specific variables.
func _init() -> void:
	resource_name = "Iron Sword"
	_rank = Ranks.D
	_might = 6
	_weight = 6
	_hit = 100
	_crit = 0
	_max_uses = 40
	_price = 2200
	_weapon_exp = 1
	_description = "A cheap, easy to wield sword."
#	effective_classes =
	super()
