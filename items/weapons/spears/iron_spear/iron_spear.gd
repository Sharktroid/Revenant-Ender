class_name Iron_Spear
extends Spear


# Weapon-specific variables.
func _init() -> void:
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
	super()
