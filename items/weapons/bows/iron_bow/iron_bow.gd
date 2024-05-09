class_name IronBow
extends Bow


# Weapon-specific variables.
func _init() -> void:
	resource_name = "Iron Bow"
	_rank = Ranks.E
	_might = 7
	_weight = 6
	_hit = 65
	_crit = 0
	_max_uses = 40
	_price = 2200
	_weapon_exp = 1
	_description = "A cheap, easy to wield bow."
#	effective_classes
	super()
