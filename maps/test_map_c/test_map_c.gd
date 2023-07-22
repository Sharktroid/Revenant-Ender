extends Map


func _init():
	faction_stack = [Faction.new("Player", Faction.colors.BLUE, Faction.player_types.HUMAN),
		Faction.new("Enemy", Faction.colors.RED, Faction.player_types.HUMAN),
	]
