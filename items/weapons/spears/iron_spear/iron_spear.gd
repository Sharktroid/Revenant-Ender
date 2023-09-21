class_name Iron_Lance
extends Spear


# Weapon-specific variables.
func _init():
	name = "Iron Spear"
	level = ranks.E
	might = 7
	weight = 9
	hit = 70
	crit = 0
	max_uses = 40
	price = 2200
	weapon_experience = 1
	_description = "A cheap, easy to wield spear."
#	effective_classes
	icon = load("uid://b5lhjgi20d8ww")
	super()
