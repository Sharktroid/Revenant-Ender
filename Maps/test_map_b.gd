extends "res://Maps/map_base.gd"


func _init():
	# Initializing variables for this map.
	faction_stack = [Faction.new("Player", Faction.colors.BLUE, Faction.player_types.HUMAN),
		Faction.new("Enemy", Faction.colors.RED, Faction.player_types.HUMAN),
	]


#func get_size() -> Vector2:
#	return $Fe6Chapter1.texture.get_size()
