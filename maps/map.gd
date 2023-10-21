class_name Map
extends Control

enum tile_types {ATTACK, MOVEMENT, SUPPORT}

# Border boundaries of the map. units should not exceed these unless aethetic
var left_border: int
var right_border: int
var top_border: int
var bottom_border: int
# See _ready() for these next two
var upper_border: Vector2i
var lower_border: Vector2i
var movement_cost_dict: Dictionary # Movement costs for every movement type
var faction_stack: Array[Faction] # All factions
var true_pos: Vector2i # Position of the map, used for scrolling
var curr_faction: int = 0

var _attack_tile_node: Resource = load("uid://c2xbtsc8bnoy5")
var _movement_tile_node: Resource = load("uid://c8vpqlssnmggo")
var _support_tile_node: Resource = load("uid://m1ftciv3g7t1")


func _enter_tree() -> void:
	MapController.map = self


func _ready() -> void:
	upper_border = Vector2i(left_border, top_border)
	lower_border = Vector2i(right_border, bottom_border)
	_parse_movement_cost()
	create_debug_borders() # Only shows up when collison shapes are enabled
	$"Map Layer/Terrain Layer".visible = GenVars.get_debug_constant("display_map_terrain")
	$"Map Layer/Debug Border Overlay Container".visible = \
			GenVars.get_debug_constant("display_map_borders")
	$"Map Layer/Cursor Area".visible = GenVars.get_debug_constant("display_map_cursor")
	size = $"Map Layer/Base Layer".get_used_cells(0).max() * 16 + Vector2i(16, 16)
	grab_focus()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ranges"):
		if MapController.get_cursor().get_hovered_unit():
			toggle_outline_unit(MapController.get_cursor().get_hovered_unit())
		else:
			toggle_full_outline()

	elif event.is_action_pressed("ui_select"):
		_on_cursor_select()

	elif event.is_action_pressed("status"):
		if MapController.get_cursor().get_hovered_unit():
			var status_menu: Control = load("uid://dfm25r0ju5214").instantiate()
			status_menu.observing_unit = MapController.get_cursor().get_hovered_unit()
			MapController.get_ui().add_child(status_menu)


func unit_wait(_unit) -> void:
	# Called whenever a unit waits.
	update_outline()


func next_faction() -> void:
	# Sets the faction to the next faction.
	curr_faction = (curr_faction + 1) % len(faction_stack)
	var turn_banner_node: Sprite2D = MapController.get_node("UI Layer/Turn Banner")
	var faction_name: String = get_current_faction().name.to_lower()
	var all_names: Array[String] = []
	var dir: DirAccess = DirAccess.open("res://Turn Banners/")
	if dir:
		dir.list_dir_begin()
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
		turn_banner_node.get_node("Banner Timer").emit_signal.call_deferred("timeout")


func get_current_faction() -> Faction:
	return faction_stack[curr_faction]


func get_faction_from_id(faction_id: int) -> Faction:
	if faction_id in faction_stack:
		return faction_stack[faction_id]
	else:
		push_error("Could not find Faction")
		return null


func get_units_by_faction(faction_id: int) -> Array[Unit]:
	var units: Array[Unit] = []
	for unit in get_tree().get_nodes_in_group("unit"):
		if unit.faction_id == faction_id:
			units.append(unit)
	return units


func get_next_unit(unit: Unit) -> Unit:
	return _get_unit_relative(unit, 1)


func get_previous_unit(unit: Unit) -> Unit:
	return _get_unit_relative(unit, -1)


func get_rel_upper_border() -> Vector2i:
	return upper_border - MapController.get_map_camera().map_position


func get_rel_lower_border() -> Vector2i:
	return lower_border - MapController.get_map_camera().get_low_map_position()


func is_touching_border(pos: Vector2i) -> bool:
	for i in 2:
		if pos[i] - 16 < upper_border[i] or pos[i] + 16 > get_size()[i] - lower_border[i]:
			return true
	return false


func start_turn() -> void:
	## Starts new turn.
	if get_current_faction().player_type != Faction.player_types.HUMAN:
		end_turn.call_deferred()


func end_turn() -> void:
	## Ends current turn.
	for unit in get_tree().get_nodes_in_group("units"):
		unit.awaken()
	next_faction()
	update_outline()


## Gets the terrain cost of the tiles at "coords".
## unit: unit trying to move over "coords".
func get_terrain_cost(unit: Unit, coords: Vector2) -> float:
	var movement_type: UnitClass.movement_types = unit.unit_class.movement_type
	if movement_type in movement_cost_dict.keys():
		var movement_type_terrain_dict = movement_cost_dict[unit.unit_class.movement_type]
		var terrain_name: String = _get_terrain(coords, unit.get_faction())
		# Combines several terrain names for compactness.
		match terrain_name:
			"HQ", "Factory", "City", "House", "Gate", "Village": terrain_name = "Road"
			"Sea": terrain_name = "Ocean"
		if terrain_name in movement_type_terrain_dict:
			var cost: String = movement_type_terrain_dict[terrain_name]
			if cost.is_valid_float():
				return float(cost)
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
				var border_tile: Sprite2D = $"Map Layer/Debug Border Overlay Tile Base".duplicate()
				border_tile.transform.origin = Vector2(x, y)
				$"Map Layer/Debug Border Overlay Container".add_child(border_tile)


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
	$"Map Layer/Outline".queue_redraw()


func display_tiles(tiles: Array[Vector2i], type: tile_types, modulation: float = 0.5,
		modulate_blacklist: Array[Vector2i] = [], blacklist_as_whitelist: bool = false) -> Node2D:
	var tiles_node := Node2D.new()
	tiles_node.name = "%s Move Tiles" % name
	var current_tile_base: PackedScene
	match type:
		tile_types.ATTACK: current_tile_base = _attack_tile_node
		tile_types.MOVEMENT: current_tile_base = _movement_tile_node
		tile_types.SUPPORT: current_tile_base = _support_tile_node
	for i in tiles:
		var tile: Sprite2D = current_tile_base.instantiate()
		tile.name = "Tile"
		tile.position = Vector2(i)
		if GenFunc.xor(not(i in modulate_blacklist), blacklist_as_whitelist):
			tile.modulate.a = modulation
		tiles_node.add_child(tile)
	get_node("Map Layer/Base Layer").add_child(tiles_node)
	return tiles_node


func display_highlighted_tiles(tiles: Array[Vector2i], unit: Unit, type: tile_types) -> Node2D:
	var unit_coords: Array[Vector2i] = []
	for e_unit in get_tree().get_nodes_in_group("units"):
		if not(e_unit.is_ghost or unit.is_friend(e_unit)) and e_unit.visible:
			unit_coords.append(Vector2i(e_unit.position))
	return display_tiles(tiles, type, 0.5, unit_coords)


func _get_terrain(coords: Vector2i, faction: Faction) -> String:
	## Gets the name of the terrain at the tile at position "coords"
	## faction: faction of the unit checking
	if coords != coords.clamp(Vector2i(), get_size() - Vector2(16, 16)):
		return "Blocked"
	for unit in get_tree().get_nodes_in_group("units"): # for units
		if coords == Vector2i(unit.transform.get_origin()):
#			if "Doesn't Block" in unit.tags:
#				return unit.unit_class
#			else:
			var blocking_stances = [Faction.diplo_stances.PEACE, Faction.diplo_stances.ENEMY]
			if faction.get_diplomacy_stance(unit.get_faction()) in blocking_stances:
				return "Blocked"
	var cell_id: TileData = $"Map Layer/Terrain Layer".get_cell_tile_data(0, coords/16)
	var cell_name_string: String = cell_id.get_custom_data("Terrain Name")
	return cell_name_string


func _parse_movement_cost() -> void:
	# Reads the movement cost from the .csv file
	var file = FileAccess.open("units/movement_cost.csv", FileAccess.READ)
	var raw_movement_cost: Array = file.get_as_text().split("\n")
	if len(raw_movement_cost[-1]) == 0:
		raw_movement_cost.erase("")
	file.close()
	var header: PackedStringArray = (raw_movement_cost.pop_at(0).strip_edges().split(","))
	header.remove_at(0)
	for full_type in raw_movement_cost:
		var split: Array = full_type.strip_edges().split(",")
		var type: UnitClass.movement_types
		match split.pop_at(0):
			"Foot": type = UnitClass.movement_types.FOOT
			"Advanced Foot": type = UnitClass.movement_types.ADVANCED_FOOT
			"Fighters": type = UnitClass.movement_types.FIGHTERS
			"Armor": type = UnitClass.movement_types.ARMOR
			"Bandits": type = UnitClass.movement_types.BANDITS
			"Pirates": type = UnitClass.movement_types.PIRATES
			"Berserker": type = UnitClass.movement_types.BERSERKER
			"Mages": type = UnitClass.movement_types.MAGES
			"Light Cavalry": type = UnitClass.movement_types.LIGHT_CAVALRY
			"Advanced Light Cavalry": type = UnitClass.movement_types.ADVANCED_LIGHT_CAVALRY
			"Heavy Cavalry": type = UnitClass.movement_types.HEAVY_CAVALRY
			"Advanced Heavy Cavalry": type = UnitClass.movement_types.ADVANCED_HEAVY_CAVALRY
			"Fliers": type = UnitClass.movement_types.FLIERS
		movement_cost_dict[type] = {}
		for cost in len(split):
			movement_cost_dict[type][header[cost]] = split[cost]


func _get_unit_relative(unit: Unit, rel_index: int) -> Unit:
	var faction_units: Array[Unit] = get_units_by_faction(unit.faction_id)
	var unit_index: int = faction_units.find(unit)
	var next_unit_index: int = (unit_index + rel_index) % len(faction_units)
	return faction_units[next_unit_index]


func _on_cursor_select() -> void:
	var hovered_unit: Unit = MapController.get_cursor().get_hovered_unit()
	if hovered_unit and hovered_unit.selectable == true:
		var controller = SelectedUnitController.new(hovered_unit)
		add_child(controller)
		MapController.selecting = true
	else:
		MapController.create_main_map_menu()
