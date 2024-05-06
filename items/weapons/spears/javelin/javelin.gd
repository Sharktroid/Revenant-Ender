class_name Javelin
extends Spear


# Weapon-specific variables.
func _init() -> void:
	name = "Javelin"
	level = Ranks.D
	might = 6
	weight = 12
	hit = 50
	crit = 0
	max_uses = 20
	price = 1200
	weapon_exp = 1
	description = "A throwing spear that can also attack\nfrom range"
	super()
	max_range = 2

