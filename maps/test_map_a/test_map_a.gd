extends Map


func _init():
	# Initializing variables for this map.
	faction_stack = [Faction.new("Player", Faction.colors.BLUE, Faction.player_types.HUMAN),
		Faction.new("Enemy", Faction.colors.RED, Faction.player_types.HUMAN),
		Faction.new("Player", Faction.colors.GREEN, Faction.player_types.HUMAN)]
	left_border = 128
	right_border = 128
	top_border = 32
	bottom_border = 16
