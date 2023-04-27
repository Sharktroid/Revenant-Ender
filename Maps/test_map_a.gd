extends "res://Maps/map_base.gd"


func _init():
	# Initializing variables for this map.
	faction_stack = [{name = "Player", color = "Blue", player_type = "Human", default_variant = "Orange Star"},
		{name = "Enemy", color = "Red", player_type = "Human", default_variant = "Blue Moon"},
		{name = "Gaia", color = "Neutral", player_type = "None", default_variant = "Orange Star"}]
	left_border = 128
	right_border = 128
	top_border = 32
	bottom_border = 16
