class_name Iron_Sword
extends Sword


# Weapon-specific variables.
func _init() -> void:
	name = "Iron Sword"
	level = ranks.E
	might = 6
	weight = 6
	hit = 70
	crit = 0
	max_uses = 40
	price = 2200
	weapon_experience = 1
#	effective_classes =
	icon = load("uid://breqnr66xl8m6")
	super()

