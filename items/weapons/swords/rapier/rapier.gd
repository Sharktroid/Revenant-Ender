class_name Rapier
extends Weapon

func _init():
	name = "Rapier"
	type = types.SWORD
	level = ranks.E
	might = 7
	weight = 5
	hit = 95
	crit = 10
	min_range = 1
	max_range = 1
	max_uses = 40
	price = 6000
	weapon_experience = 2
#	effective_classes
	icon = load("uid://t4df6i6ew06w")
	super()
