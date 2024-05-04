class_name IronBow
extends Bow


# Weapon-specific variables.
func _init() -> void:
	name = "Iron Bow"
	level = ranks.E
	might = 7
	weight = 6
	hit = 65
	crit = 0
	max_uses = 40
	price = 2200
	weapon_exp = 1
	description = "A cheap, easy to wield bow."
#	effective_classes
	super()
