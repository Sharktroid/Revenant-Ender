class_name Iron_Bow
extends Weapon


# Weapon-specific variables.
func _init():
	name = "Iron Bow"
	type = types.BOW
	level = ranks.E
	might = 8
	weight = 5
	hit = 80
	crit = 0
	min_range = 2
	max_range = 2
	max_uses = 40
#	current_durability
#	price
#	weapon_experience
#	effective_classes
	super()
