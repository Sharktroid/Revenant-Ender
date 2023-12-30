class_name Silver_Lance
extends Spear


# Weapon-specific variables.
func _init() -> void:
	name = "Silver Spear"
	level = ranks.A
	might = 15
	weight = 10
	hit = 75
	crit = 0
	max_uses = 20
	price = 4000
	weapon_experience = 1
	_description = "A very powerful and expensive spear."
	icon = preload("uid://cvkwhxmqlavgm")
	super()

