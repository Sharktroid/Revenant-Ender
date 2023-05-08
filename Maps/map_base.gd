class_name Map
extends CanvasLayer

# Border boundaries of the map. units should not exceed these unless aethetic
var left_border: int
var right_border: int
var top_border: int
var bottom_border: int
# See _ready() for these next two
var upper_border: Vector2i
var lower_border: Vector2i
var movement_cost_dict: Dictionary # Movement costs for every movement type
#var diplomacy: Dictionary # Diplomacy of every current faction
var faction_stack: Array[Faction] # All factions
var true_pos: Vector2i # Position of the map, used for scrolling
var curr_faction: int = 0


func _ready() -> void:
	upper_border = Vector2i(left_border, top_border)
	lower_border = Vector2i(right_border, bottom_border)
	_parse_movement_cost()
	create_debug_borders() # Only shows up when collison shapes are enabled
	$"Terrain Layer".visible = GenVars.get_debug_constant("display_map_terrain")
	$"Debug Border Overlay Container".visible = GenVars.get_debug_constant("display_map_borders")
	$"Cursor Area".visible = GenVars.get_debug_constant("display_map_cursor")


func unit_wait(_unit) -> void:
	# Called whenever a unit waits.
	update_outline()
	for unit in get_tree().get_nodes_in_group("units"):
		unit.reset_tiles()


func next_faction() -> void:
	# Sets the faction to the next faction.
	curr_faction = (curr_faction + 1) % len(faction_stack)
	var turn_banner_node: Sprite2D = GenVars.get_level_controller().get_node("UILayer/Turn Banner")
	var faction_name: String = get_current_faction().name.to_lower()
	var all_names: Array[String] = []
	var dir = DirAccess.open("res://Turn Banners/")
	if dir:
		dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file_name: String = dir.get_next()
		while file_name != "":
			all_names.append(file_name.split("_")[0])
			file_name = dir.get_next()
	else:
		push_error('An error occurred when trying to access the path "res://Turn Banners/".')
	# Only displays factions with banners.
	if faction_name in all_names:
		turn_banner_node.texture = load("res://Turn Banners/%s_phase_banner.png" % faction_name)
		turn_banner_node.get_node("Banner Timer").start()
	# When there is no banner.
	else:
		await get_tree().idle_frame
		turn_banner_node.get_node("Banner Timer").emit_signal("timeout")


func get_current_faction() -> Faction:
	return faction_stack[curr_faction]


func get_faction(faction_id: int) -> Faction:
	if faction_id in faction_stack:
		return faction_stack[faction_id]
	else:
		push_error("Could not find Faction")
		return null


func get_rel_upper_border() -> Vector2i:
	return upper_border - (GenVars.get_map_camera() as MapCamera).map_position


func get_rel_lower_border() -> Vector2i:
	return lower_border - (GenVars.get_map_camera() as MapCamera).get_low_map_position()


func get_size() -> Vector2i:
	# Returns size of the map.
	return $"Base Layer".get_used_cells(0).max() * 16 + Vector2i(16, 16)


func is_touching_border(pos: Vector2i) -> bool:
	for i in 2:
		if pos[i] - 16 < upper_border[i] or pos[i] + 16 > get_size()[i] - lower_border[i]:
			return true
	return false


func start_turn() -> void:
	# Starts new turn.
	if get_current_faction().player_type != Faction.player_types.HUMAN:
		_wait_end_turn()


func end_turn() -> void:
	# Ends current turn.
	for unit in get_tree().get_nodes_in_group("units"):
		unit.awaken()
	next_faction()
	update_outline()


func get_terrain_cost(unit: Unit, coords: Vector2) -> int:
	## Gets the terrain cost of the tiles at "coords".
	## unit: unit trying to move over "coords".
	var movement_type: String = unit.movement_type
	if movement_type in movement_cost_dict.keys():
		var movement_type_terrain_dict: Dictionary = movement_cost_dict[unit.movement_type]
		var terrain_name: String = _get_terrain(coords, unit.get_faction())
		# Combines several terrain names for compactness.
		match terrain_name:
			"HQ", "Factory", "City", "House", "Gate", "Village": terrain_name = "Road"
			"Sea": terrain_name = "Ocean"
		if terrain_name in movement_type_terrain_dict:
			var cost: String = movement_type_terrain_dict[terrain_name]
			if cost.is_valid_int():
				return int(cost)
			elif cost in "N/A":
				return 99
			else:
				push_error('Terrain cost "%s" is invalid' % cost)
		else:
			push_error('Terrain "%s" is invalid' % terrain_name)
	else:
		push_error('Movement type "%s" is invalid' % movement_type)
	return 99


func create_debug_borders() -> void:
	# Creates a visualization of the map's borders
	for x in range(0, get_size().x, 16):
		for y in range(0, get_size().y, 16):
			if x < left_border or x + 16 > get_size().x - right_border \
					or y < top_border or y + 16 > get_size().y - bottom_border:
				var border_tile: Sprite2D = $"Debug Border Overlay Tile Base".duplicate()
				border_tile.transform.origin = Vector2(x, y)
				$"Debug Border Overlay Container".add_child(border_tile)


func toggle_full_outline() -> void:
	faction_stack[curr_faction].full_outline = not(get_current_faction().full_outline)
	update_outline()


func toggle_outline_unit(unit: Unit) -> void:
	var outlined_units: Dictionary = get_current_faction().outlined_units
	if not(unit.get_faction() in outlined_units):
		outlined_units[unit.get_faction()] = []
	if unit in outlined_units[unit.get_faction()]:
		outlined_units[unit.get_faction()].erase(unit)
	else:
		outlined_units[unit.get_faction()].append(unit)
	faction_stack[curr_faction].outlined_units = outlined_units
	update_outline()


func update_outline() -> void:
	$"Base Layer/Outline".queue_redraw()


func _wait_end_turn() -> void:
	# Ends turn on the next frame; here so "start_turn" finishes before "end_turn" starts
	await get_tree().idle_frame
	end_turn()


func _get_terrain(coords: Vector2i, faction: Faction) -> String:
	# Gets the name of the terrain at the tile at position "coords"
	# faction: faction of the unit checking
	for unit in get_tree().get_nodes_in_group("units"): # for units
		if coords == (unit.transform.get_origin() as Vector2i):
			if "Doesn't Block" in unit.tags:
				return unit.unit_class
			else:
				var blocking_stances: Array = [Faction.diplo_stances.PEACE, Faction.diplo_stances.ENEMY]
				if faction.get_diplomacy_stance(unit.get_faction()) in blocking_stances:
					return "Blocked"
	var cell_id: TileData = $"Terrain Layer".get_cell_tile_data(0, coords/16)
	return cell_id.get_custom_data("Terrain Name")


func _parse_movement_cost() -> void:
	# Reads the movement cost from the .csv file
	var file = FileAccess.open("res://movement_cost.csv", FileAccess.READ)
	var raw_movement_cost: Array = file.get_as_text().split("\n")
	if len(raw_movement_cost[-1]) == 0:
		raw_movement_cost.erase("")
	file.close()
	var header: Array = raw_movement_cost.pop_at(0).split(",")
	header.remove_at(0)
	for full_type in raw_movement_cost:
		var split: Array = full_type.split(",")
		var type = split.pop_at(0)
		movement_cost_dict[type] = {}
		for cost in len(split):
			movement_cost_dict[type][header[cost]] = split[cost]
