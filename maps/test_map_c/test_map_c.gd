extends Map


func _init() -> void:
	all_factions = [Faction.new("Player", Faction.Colors.BLUE, Faction.PlayerTypes.HUMAN),
		Faction.new("Enemy", Faction.Colors.RED, Faction.PlayerTypes.HUMAN),
	]
