@tool
extends Map


func _init() -> void:
	# Initializing variables for this map.
	all_factions = [
		Faction.new(
			"Roy's Army",
			Faction.Colors.BLUE,
			Faction.PlayerTypes.HUMAN,
			preload("res://audio/music/beyond_distant_skies.ogg")
		),
		Faction.new(
			"Bandits",
			Faction.Colors.RED,
			Faction.PlayerTypes.COMPUTER,
			preload("res://audio/music/deer_of_the_plains.ogg"),
			true
		),
	]
	super()


func _intro() -> void:
	if not _get_dialogue().is_node_ready():
		await _get_dialogue().ready
	#await _run_script(&"intro")
