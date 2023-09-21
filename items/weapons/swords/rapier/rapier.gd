class_name Rapier
extends Sword

func _init():
	name = "Rapier"
	level = ranks.C
	might = 7
	weight = 5
	hit = 95
	crit = 10
	max_uses = 40
	price = 6000
	weapon_experience = 2
	_description = "A thin, nimble sword.\nx1.5 bonus damage against cavalry and armored units"
#	effective_classes
	icon = load("uid://t4df6i6ew06w")
	super()
