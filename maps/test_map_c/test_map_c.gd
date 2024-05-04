extends Map


func _init() -> void:
	all_factions = [Faction.new("Player", Faction.colors.BLUE, Faction.playerTypes.HUMAN),
		Faction.new("Enemy", Faction.colors.RED, Faction.playerTypes.HUMAN),
	]
