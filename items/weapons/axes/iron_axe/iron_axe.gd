class_name Iron_Axe
extends Axe


# Weapon-specific variables.
func _init() -> void:
	name = "Iron Axe"
	level = ranks.E
	might = 9
	weight = 10
	hit = 65
	crit = 0
	max_uses = 30
	price = 1100
	weapon_exp = 1
	description = "A cheap, easy to wield axe."
	super()
