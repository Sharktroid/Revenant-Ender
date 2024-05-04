extends Map


func _init():
	# Initializing variables for this map.
	all_factions = [Faction.new("Player", Faction.colors.BLUE, Faction.playerTypes.HUMAN),
		Faction.new("Enemy", Faction.colors.RED, Faction.playerTypes.HUMAN),
		Faction.new("Player", Faction.colors.GREEN, Faction.playerTypes.HUMAN)]
	left_border = 128
	right_border = 128
	top_border = 32
	bottom_border = 16
