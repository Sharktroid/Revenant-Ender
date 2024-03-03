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
	max_uses = 20
	price = 1200
	weapon_experience = 1
	_description = "A throwing spear that can also attack\nfrom range"
	icon = preload("res://items/weapons/spears/javelin/icon.png")
	super()
	max_range = 2

