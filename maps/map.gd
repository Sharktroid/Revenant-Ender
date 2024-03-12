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
var all_factions: Array[Faction] # All factions
var true_pos: Vector2i # Position of the map, used for scrolling
var curr_faction: int = 0

var _cost_grids: Dictionary = {}
var _grid_current_faction: Faction

@onready var _terrain_layer := $"Map Layer/Terrain Layer" as TileMap
@onready var _border_overlay := $"Map Layer/Debug Border Overlay Container" as CanvasGroup


func _init() -> void:
	upper_border = Vector2i(left_border, top_border)
	lower_border = Vector2i(right_border, bottom_border)
	_parse_movement_cost()


func _ready() -> void:
	create_debug_borders() # Only shows up when collison shapes are enabled
	_terrain_layer.visible = Utilities.get_debug_constant("display_map_terrain")
	_border_overlay.visible = Utilities.get_debug_constant("display_map_borders")
	($"Map Layer/Cursor Area" as Area2D).visible = \
			Utilities.get_debug_constant("display_map_cursor")
	var cell_max: Vector2i = ($"Map Layer/Base Layer" as TileMap).get_used_cells(0).max()
	size = cell_max * 16 + Vector2i(16, 16)
	GameController.add_to_input_stack(self)
	const TYPES = UnitClass.movement_types
	for movement_type: TYPES in movement_cost_dict.keys() as Array[TYPES]:
		var a_star_grid := AStarGrid2D.new()
		a_star_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
		a_star_grid.region = Rect2i(Vector2i(0, 0), cell_max + Vector2i(1, 1))
		a_star_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
		a_star_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
		a_star_grid.jumping_enabled = false
		a_star_grid.update()
		for cell: Vector2i in ($"Map Layer/Base Layer" as TileMap).get_used_cells(0):
			update_a_star_grid_id(a_star_grid, movement_type, cell)
		_cost_grids[movement_type] = a_star_grid


func receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ranges"):
		if CursorController.get_hovered_unit():
			toggle_outline_unit(CursorController.get_hovered_unit())
		else:
			toggle_full_outline()

	elif event.is_action_pressed("ui_select"):
		_on_cursor_select()

	elif event.is_action_pressed("status"):
		if CursorController.get_hovered_unit():
			const STATUS_SCREEN = preload("res://ui/map_ui/status_screen/status_screen.gd")
			const STATUS_SCREEN_SCENE: PackedScene = \
					preload("res://ui/map_ui/status_screen/status_screen.tscn")
			var status_menu := STATUS_SCREEN_SCENE.instantiate() as STATUS_SCREEN
			status_menu.observing_unit = CursorController.get_hovered_unit()
			MapController.get_ui().add_child(status_menu)
			GameController.add_to_input_stack(status_menu)
			CursorController.disable()


func unit_wait(_unit: Unit) -> void:
	# Called whenever a unit waits.
	update_outline()


func next_faction() -> void:
	# Sets the faction to the next faction.
	curr_faction = (curr_faction + 1) % len(all_factions)
	var turn_banner_node := MapController.get_ui().get_node("Turn Banner") as Sprite2D
	var faction_name: String = get_current_faction().name.to_lower()
	var all_names: Array[String] = []
	var dir: DirAccess = DirAccess.open("res://turn_banners/")
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			all_names.append(file_name.split("_")[0])
			file_name = dir.get_next()
	else:
		push_error('An error occurred when trying to access the path "res://turn_banners/".')
	# Only displays factions with banners.
	if faction_name in all_names:
		turn_banner_node.texture = \
				load("res://turn_banners/%s_phase_banner.png" % faction_name) as Texture2D
		var timer: SceneTreeTimer = get_tree().create_timer(82.0/60)
		await timer.timeout
		turn_banner_node.texture = null
	# When there is no banner.
	else:
		turn_banner_node.get_node("Banner Timer").emit_signal.call_deferred("timeout")


func get_current_faction() -> Faction:
	return all_factions[curr_faction]


func get_units_by_faction(faction_id: int) -> Array[Unit]:
	var units: Array[Unit] = []
	for unit: Unit in MapController.get_units():
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
	for i: int in 2:
		if pos[i] - 16 < upper_border[i] or pos[i] + 16 > get_size()[i] - lower_border[i]:
			return true
	return false


func start_turn() -> void:
	## Starts new turn.
	if get_current_faction().player_type != Faction.player_types.HUMAN:
		end_turn.call_deferred()


func end_turn() -> void:
	## Ends current turn.
	for unit: Unit in MapController.get_units():
		unit.awaken()
	next_faction()
	update_outline()


## Gets the terrain cost of the tiles at "coords".
## unit: unit trying to move over "coords".
func get_terrain_cost(movement_type: UnitClass.movement_types, coords: Vector2) -> float:
	if movement_type in movement_cost_dict.keys():
		var movement_type_terrain_dict: Dictionary = movement_cost_dict[movement_type]
		var terrain_name: String = _get_terrain(coords)
		# Combines several terrain names for compactness.
		match terrain_name:
			"HQ", "Factory", "City", "House", "Gate", "Village": terrain_name = "Road"
			"Sea": terrain_name = "Ocean"
		if terrain_name in movement_type_terrain_dict:
			var cost: String = movement_type_terrain_dict[terrain_name]
			if cost.is_valid_float():
				return float(cost)
			elif cost in "N/A":
				return INF
			else:
				push_error('Terrain cost "%s" is invalid' % cost)
		else:
			push_error('Terrain "%s" is invalid' % terrain_name)
	else:
		push_error('Movement type "%s" is invalid' % movement_type)
	return INF


func create_debug_borders() -> void:
	# Creates a visualization of the map's borders
	for x: int in range(0, get_size().x, 16):
		for y: int in range(0, get_size().y, 16):
			if x < left_border or x + 16 > get_size().x - right_border \
					or y < top_border or y + 16 > get_size().y - bottom_border:
				var border_tile := \
						$"Map Layer/Debug Border Overlay Tile Base".duplicate() as Sprite2D
				border_tile.transform.origin = Vector2(x, y)
				_border_overlay.add_child(border_tile)


func toggle_full_outline() -> void:
	all_factions[curr_faction].full_outline = not(get_current_faction().full_outline)
	update_outline()


func toggle_outline_unit(unit: Unit) -> void:
	var outlined_units: Dictionary = get_current_faction().outlined_units
	if not(unit.get_faction() in outlined_units):
		outlined_units[unit.get_faction()] = []
	if unit in outlined_units[unit.get_faction()]:
		(outlined_units[unit.get_faction()] as Array).erase(unit)
	else:
		(outlined_units[unit.get_faction()] as Array).append(unit)
	all_factions[curr_faction].outlined_units = outlined_units
	update_outline()


func update_outline() -> void:
	($"Map Layer/Outline" as Node2D).queue_redraw()


func display_tiles(tiles: Array[Vector2i], type: tile_types, modulation: float = 0.5,
		modulate_blacklist: Array[Vector2i] = [], blacklist_as_whitelist: bool = false) -> Node2D:
	var tiles_node := Node2D.new()
	tiles_node.name = "%s Move Tiles" % name
	var current_tile_base: PackedScene
	const ATTACK_TILE_NODE: PackedScene = preload("res://maps/map_tiles/attack_tile.tscn")
	const MOVEMENT_TILE_NODE: PackedScene = preload("res://maps/map_tiles/movement_tile.tscn")
	const SUPPORT_TILE_NODE: PackedScene = preload("res://maps/map_tiles/support_tile.tscn")
	match type:
		tile_types.ATTACK: current_tile_base = ATTACK_TILE_NODE
		tile_types.MOVEMENT: current_tile_base = MOVEMENT_TILE_NODE
		tile_types.SUPPORT: current_tile_base = SUPPORT_TILE_NODE
	for i: Vector2i in tiles:
		var tile := current_tile_base.instantiate() as Sprite2D
		tile.name = "Tile"
		tile.position = Vector2(i)
		if Utilities.xor(not(i in modulate_blacklist), blacklist_as_whitelist):
			tile.modulate.a = modulation
		tiles_node.add_child(tile)
	get_node("Map Layer/Base Layer").add_child(tiles_node)
	return tiles_node


func display_highlighted_tiles(tiles: Array[Vector2i], unit: Unit, type: tile_types) -> Node2D:
	var unit_coords: Array[Vector2i] = []
	for e_unit: Unit in MapController.get_units():
		if not(unit.is_friend(e_unit)) and e_unit.visible:
			unit_coords.append(Vector2i(e_unit.position))
	return display_tiles(tiles, type, 0.5, unit_coords)


func get_movement_path(movement_type: UnitClass.movement_types, starting_point: Vector2i,
		destination: Vector2i, faction: Faction) -> Array[Vector2i]:
	if faction != _grid_current_faction:
		_grid_current_faction = faction
		_update_grid_current_faction()
	var movement_grid: AStarGrid2D = _cost_grids[movement_type]
	var output: Array[Vector2i] = []
	if (movement_grid.is_in_boundsv(starting_point / 16)
			and movement_grid.is_in_boundsv(destination / 16)):
		var raw_path: PackedVector2Array = \
				movement_grid.get_point_path(starting_point / 16, destination / 16)
		for vector: Vector2i in raw_path:
			output.append(vector * 16)
	return output


func get_movement_cost(movement_type: UnitClass.movement_types, starting_point: Vector2i,
		destination: Vector2i, faction: Faction) -> float:
	var movement_grid: AStarGrid2D = _cost_grids[movement_type]
	var path: Array[Vector2i] = get_movement_path(movement_type, starting_point, destination,
			faction)
	if path == []:
		return INF
	else:
		var sum: float = 0
		for cell: Vector2i in path:
			if cell != starting_point:
				sum += movement_grid.get_point_weight_scale(cell / 16)
		return sum


func update_a_star_grid_id(a_star_grid: AStarGrid2D, movement_type: UnitClass.movement_types,
		id: Vector2i) -> void:
	var weight: float = get_terrain_cost(movement_type, id * 16)
	if weight == INF:
		a_star_grid.set_point_solid(id)
	else:
		a_star_grid.set_point_weight_scale(id, weight)


func _get_terrain(coords: Vector2i) -> String:
	## Gets the name of the terrain at the tile at position "coords"
	if coords != coords.clamp(Vector2i(), get_size() - Vector2(16, 16)):
		return "Blocked"
	var cell_id: TileData = _terrain_layer.get_cell_tile_data(0, coords/16)
	return cell_id.get_custom_data("Terrain Name")


func _parse_movement_cost() -> void:
	# Reads the movement cost from the .csv file
	var file := FileAccess.open("units/movement_cost.csv", FileAccess.READ)
	var raw_movement_cost: Array[String] = []
	raw_movement_cost.assign(file.get_as_text().split("\n"))
	if len(raw_movement_cost[-1]) == 0:
		raw_movement_cost.erase("")
	file.close()
	var header: Array[String] = []
	header.assign((raw_movement_cost.pop_at(0) as String).strip_edges().split(","))
	header.remove_at(0)
	for full_type: String in raw_movement_cost:
		var split: Array[String] = []
		split.assign(full_type.strip_edges().split(","))
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
		for cost: int in len(split):
			movement_cost_dict[type][header[cost]] = split[cost]


func _get_unit_relative(unit: Unit, rel_index: int) -> Unit:
	var faction_units: Array[Unit] = get_units_by_faction(unit.faction_id)
	var unit_index: int = faction_units.find(unit)
	var next_unit_index: int = (unit_index + rel_index) % len(faction_units)
	return faction_units[next_unit_index]


func _on_cursor_select() -> void:
	var hovered_unit: Unit = CursorController.get_hovered_unit()
	if hovered_unit and hovered_unit.selectable == true:
		var controller := SelectedUnitController.new(hovered_unit)
		add_child(controller)
		MapController.selecting = true
	else:
		MapController.create_main_map_menu()


func _update_grid_current_faction() -> void:
	for movement_type: UnitClass.movement_types in _cost_grids.keys():
		var a_star_grid: AStarGrid2D = _cost_grids[movement_type]
		for unit: Unit in MapController.get_units():
			a_star_grid.set_point_solid(unit.position / 16,
					not unit.get_faction().is_friend(_grid_current_faction))

