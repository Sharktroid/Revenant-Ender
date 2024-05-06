class_name SteelAxe
extends Axe


# Weapon-specific variables.
func _init() -> void:
	name = "Steel Axe"
	level = Ranks.D
	might = 13
	weight = 15
	hit = 55
	crit = 0
	max_uses = 25
	price = 1700
	weapon_exp = 2
	description = "A strong, quality axe."
	super()
