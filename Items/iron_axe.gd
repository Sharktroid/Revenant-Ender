class_name Iron_Axe
extends "res://Items/weapon.gd"


# Weapon-specific variables.
func _init():
	level = ranks.E
	might = 8
	weight = 10
	hit = 75
	crit = 0
	min_range = 1
	max_range = 1
	max_durability = 45
	current_durability = 45
	price = 270
	weapon_experience = 1
