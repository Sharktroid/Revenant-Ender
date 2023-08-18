class_name Javelin
extends Spear


# Weapon-specific variables.
func _init() -> void:
	name = "Javelin"
	level = ranks.D
	might = 6
	weight = 12
	hit = 50
	crit = 0
	max_range = 2
	max_uses = 20
	price = 1200
	weapon_experience = 1
	icon = load("uid://sn55tj54i6k")
	super()

