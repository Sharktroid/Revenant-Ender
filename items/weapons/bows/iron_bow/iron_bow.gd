class_name IronBow
extends Bow


# Weapon-specific variables.
func _init() -> void:
	resource_name = "Iron Bow"
	_rank = Ranks.D
	_hit = 100
	_might = 8
	_crit = 0
	_weight = 6
	_max_uses = 20
	_price = 2200
	_weapon_exp = 1
	_description = "A cheap, easy to wield bow."
#	effective_classes
	super()
