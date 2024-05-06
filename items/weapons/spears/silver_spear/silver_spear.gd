class_name SilverLance
extends Spear


# Weapon-specific variables.
func _init() -> void:
	name = "Silver Spear"
	level = Ranks.A
	might = 15
	weight = 10
	hit = 75
	crit = 0
	max_uses = 20
	price = 4000
	weapon_exp = 1
	description = "A very powerful and expensive spear."
	super()

