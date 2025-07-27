class_name DebugBow
extends Bow


# Weapon-specific variables.
func _init() -> void:
	resource_name = "Debug Bow"
	_rank = Ranks.D
	_might = INF
	_weight = INF
	_hit = INF
	_crit = INF
	_max_uses = INF
	_price = 2200
	_weapon_exp = 1
	_description = "A cheap, easy to wield bow."
#	effective_classes
	_min_range = 1
	_max_range = INF
	super()
