class_name Map
extends ReferenceRect

enum TileTypes { ATTACK, MOVEMENT, SUPPORT }

# Border boundaries of the map. units should not exceed these unless aesthetic
@export var _left_border: int
@export var _right_border: int
@export var _top_border: int
@export var _bottom_border: int
# See _ready() for these next two
var borders: Rect2i
var all_factions: Array[Faction]  # All factions

var _movement_cost_dict: Dictionary  # Movement costs for every movement type
var _current_faction: int = 0
var _cost_grids: Dictionary = {}
var _grid_current_faction: Faction
var _current_turn: int

@onready var _terrain_layer := $MapLayer/TerrainLayer as TileMapLayer
@onready var _base_layer := $MapLayer/BaseLayer as TileMapLayer
@onready var _border_overlay := $MapLayer/DebugBorderOverlayContainer as CanvasGroup


func _init() -> void:
	_parse_movement_cost()


func _ready() -> void:
	borders = Rect2i(_left_border * 16, _top_border * 16, 32, 32)
	borders = borders.expand(get_size() - Vector2(_right_border * 16, _bottom_border * 16))
	_create_debug_borders()  # Only shows up when collision shapes are enabled
	_terrain_layer.visible = DebugConfig.DISPLAY_MAP_TERRAIN.value
	_border_overlay.visible = DebugConfig.DISPLAY_MAP_BORDERS.value
	($MapLayer/CursorArea as Area2D).visible = DebugConfig.DISPLAY_MAP_CURSOR.value
	var cell_max: Vector2i = _base_layer.get_used_cells().max()
	size = cell_max * 16 + Vector2i(16, 16)
	GameController.add_to_input_stack(self)
	const TYPES = UnitClass.MovementTypes
	for movement_type: TYPES in _movement_cost_dict.keys() as Array[TYPES]:
		var a_star_grid := AStarGrid2D.new()
		a_star_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
		a_star_grid.region = Rect2i(Vector2i(0, 0), cell_max + Vector2i(1, 1))
		a_star_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
		a_star_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
		a_star_grid.jumping_enabled = false
		a_star_grid.update()
		for cell: Vector2i in _base_layer.get_used_cells():
			_update_a_star_grid_id(a_star_grid, movement_type, cell)
		_cost_grids[movement_type] = a_star_grid
	await _intro()
	if not MapController.get_ui().is_node_ready():
		await MapController.get_ui().ready
	_start_turn()


func _receive_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		if CursorController.is_active():
			_on_cursor_select()

	elif event.is_action_pressed("ranges"):
		if CursorController.get_hovered_unit():
			_toggle_outline_unit(CursorController.get_hovered_unit())
		else:
			_toggle_full_outline()

	elif event.is_action_pressed("status"):
		if CursorController.get_hovered_unit():
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_SELECT)
			var status_menu := StatusScreen.instantiate(CursorController.get_hovered_unit())
			MapController.get_ui().add_child(status_menu)
			GameController.add_to_input_stack(status_menu)
			CursorController.disable()


func unit_wait(_unit: Unit) -> void:
	# Called whenever a unit waits.
	_update_outline()
	for unit: Unit in get_units():
		unit.reset_tile_cache()


func get_current_faction() -> Faction:
	return all_factions[_current_faction]


func get_units_by_faction(faction: Faction) -> Array[Unit]:
	var units: Array[Unit] = []
	for unit: Unit in get_units():
		if unit.faction == faction:
			units.append(unit)
	return units


func get_next_unit(unit: Unit) -> Unit:
	return _get_unit_relative(unit, 1)


func get_previous_unit(unit: Unit) -> Unit:
	return _get_unit_relative(unit, -1)


func end_turn() -> void:
	## Ends current turn.
	for unit: Unit in MapController.map.get_units():
		unit.awaken()
	_next_faction()
	_update_outline()
	_start_turn.call_deferred()


## Gets the terrain cost of the tiles at "coords".
## unit: unit trying to move over "coords".
func get_terrain_cost(movement_type: UnitClass.MovementTypes, coords: Vector2) -> float:
	if movement_type in _movement_cost_dict.keys():
		var movement_type_terrain_dict: Dictionary = _movement_cost_dict[movement_type]
		var terrain_name: String = _get_terrain(coords)
		# Combines several terrain names for compactness.
		match terrain_name:
			"HQ", "Factory", "City", "House", "Gate", "Village":
				terrain_name = "Road"
			"Sea":
				terrain_name = "Ocean"
		if terrain_name in movement_type_terrain_dict:
			var cost: String = movement_type_terrain_dict[terrain_name]
			if cost.is_valid_float():
				return float(cost)
			if cost in "N/A":
				return INF
			push_error('Terrain cost "%s" is invalid' % cost)
		else:
			push_error('Terrain "%s" is invalid' % terrain_name)
	else:
		push_error('Movement type "%s" is invalid' % movement_type)
	return INF


func display_tiles(
	tiles: Array[Vector2i],
	type: TileTypes,
	modulation: float = 0.5,
	modulate_blacklist: Array[Vector2i] = [],
	blacklist_as_whitelist: bool = false
) -> Node2D:
	var tiles_node := Node2D.new()
	tiles_node.name = "%s Move Tiles" % name
	var current_tile_base := MovementTile
	match type:
		TileTypes.ATTACK:
			current_tile_base = preload("res://maps/map_tiles/attack_tile.gd")
		TileTypes.MOVEMENT:
			current_tile_base = MovementTile
		TileTypes.SUPPORT:
			current_tile_base = preload("res://maps/map_tiles/support_tile.gd")
	for i: Vector2i in tiles:
		var tile := current_tile_base.instantiate(
			Vector2(i),
			(
				modulation
				if Utilities.xor(not (i in modulate_blacklist), blacklist_as_whitelist)
				else 1.0
			)
		)
		tiles_node.add_child(tile)
	_base_layer.add_child(tiles_node)
	return tiles_node


func display_highlighted_tiles(tiles: Array[Vector2i], unit: Unit, type: TileTypes) -> Node2D:
	var unit_coords: Array[Vector2i] = []
	for e_unit: Unit in MapController.map.get_units():
		if not (unit.is_friend(e_unit)) and e_unit.visible:
			unit_coords.append(Vector2i(e_unit.position))
	return display_tiles(tiles, type, 0.5, unit_coords)


func get_movement_path(
	movement_type: UnitClass.MovementTypes,
	starting_point: Vector2i,
	destination: Vector2i,
	faction: Faction
) -> Array[Vector2i]:
	if faction != _grid_current_faction:
		_grid_current_faction = faction
		_update_grid_current_faction()
	var movement_grid: AStarGrid2D = _cost_grids[movement_type]
	var output: Array[Vector2i] = []
	if (
		movement_grid.is_in_boundsv(starting_point / 16)
		and movement_grid.is_in_boundsv(destination / 16)
	):
		var raw_path: PackedVector2Array = movement_grid.get_point_path(
			starting_point / 16, destination / 16
		)
		for vector: Vector2i in raw_path:
			output.append(vector * 16)
	return output


func get_path_cost(movement_type: UnitClass.MovementTypes, path: Array[Vector2i]) -> float:
	if path.size() == 0:
		return INF
	var sum: float = 0
	path.remove_at(0)
	for cell: Vector2i in path:
		sum += get_terrain_cost(movement_type, cell)
	return sum


func get_units() -> Array[Unit]:
	var units: Array[Unit] = []
	if is_inside_tree():
		for node: Node in get_tree().get_nodes_in_group("unit"):
			units.append(node)
	return units


func update_position_terrain_cost(pos: Vector2i) -> void:
	for movement_type: UnitClass.MovementTypes in _cost_grids.keys():
		var a_star_grid: AStarGrid2D = _cost_grids[movement_type]
		var point_id: Vector2i = pos / 16
		_update_a_star_grid_id(a_star_grid, movement_type, point_id)
		a_star_grid.set_point_solid(point_id, false)
	for unit: Unit in get_units():
		if unit.position == Vector2(pos):
			_update_grid_current_faction()


## Returns the [Map]'s [MapCamera].
func get_map_camera() -> MapCamera:
	var path: String = NodePath("%s/MapCamera" % get_path())
	return (get_node(path) as MapCamera) if has_node(path) else MapCamera.new()


func is_faction_friendly_to_player(faction: Faction) -> bool:
	for human_faction: Faction in all_factions:
		if (
			human_faction.player_type == Faction.PlayerTypes.HUMAN
			and faction.is_friend(human_faction)
		):
			return true
	return false


func _update_a_star_grid_id(
	a_star_grid: AStarGrid2D, movement_type: UnitClass.MovementTypes, id: Vector2i
) -> void:
	var weight: float = get_terrain_cost(movement_type, id * 16)
	if weight == INF:
		a_star_grid.set_point_solid(id)
	else:
		a_star_grid.set_point_weight_scale(id, weight)


## Creates map menu.
func _create_main_map_menu() -> void:
	const MainMapMenu = preload("res://ui/map_ui/map_menus/main_map_menu/main_map_menu.gd")
	var menu := MainMapMenu.instantiate(CursorController.screen_position + Vector2i(16, 0))
	MapController.get_ui().add_child(menu)
	GameController.add_to_input_stack(menu)
	CursorController.disable()


func _intro() -> void:
	await get_tree().process_frame


func _get_terrain(coords: Vector2i) -> String:
	## Gets the name of the terrain at the tile at position "coords"'
	return (
		"Blocked"
		if not borders.has_point(coords)
		else _terrain_layer.get_cell_tile_data(coords / 16).get_custom_data("TerrainName")
	)


func _create_debug_borders() -> void:
	# Creates a visualization of the map's borders
	for x: int in range(0, get_size().x, 16):
		for y: int in range(0, get_size().y, 16):
			if (
				x < borders.position.x
				or x + 16 > borders.end.x
				or y < borders.position.y
				or y + 16 > borders.end.y
			):
				var border_tile := $MapLayer/DebugBorderOverlayTileBase.duplicate() as Sprite2D
				border_tile.position = Vector2(x, y)
				border_tile.visible = true
				_border_overlay.add_child(border_tile)


func _parse_movement_cost() -> void:
	# Reads the movement cost from the .csv file
	var file := FileAccess.open("units/movement_cost.csv", FileAccess.READ)
	var raw_movement_cost: Array[String] = []
	raw_movement_cost.assign(file.get_as_text().split("\n"))
	if raw_movement_cost[-1].length() == 0:
		raw_movement_cost.erase("")
	file.close()
	var header: Array[String] = []
	header.assign((raw_movement_cost.pop_at(0) as String).strip_edges().split(","))
	header.remove_at(0)
	for full_type: String in raw_movement_cost:
		var split: Array[String] = []
		split.assign(full_type.strip_edges().split(","))
		var type_name: String = (split.pop_at(0) as String).to_snake_case().to_upper()
		var type: UnitClass.MovementTypes = UnitClass.MovementTypes[type_name]
		_movement_cost_dict[type] = {}
		for cost: int in split.size():
			_movement_cost_dict[type][header[cost]] = split[cost]


func _get_unit_relative(unit: Unit, rel_index: int) -> Unit:
	var faction_units: Array[Unit] = get_units_by_faction(unit.faction)
	var unit_index: int = faction_units.find(unit)
	var next_unit_index: int = (unit_index + rel_index) % faction_units.size()
	return faction_units[next_unit_index]


func _on_cursor_select() -> void:
	var hovered_unit: Unit = CursorController.get_hovered_unit()
	if hovered_unit and hovered_unit.selectable == true:
		AudioPlayer.play_sound_effect(preload("res://audio/sfx/double_select.ogg"))
		var controller := SelectedUnitController.new(hovered_unit)
		add_child(controller)
	else:
		AudioPlayer.play_sound_effect(preload("res://audio/sfx/menu_open.ogg"))
		_create_main_map_menu()


func _update_grid_current_faction() -> void:
	for movement_type: UnitClass.MovementTypes in _cost_grids.keys():
		var a_star_grid: AStarGrid2D = _cost_grids[movement_type]
		for unit: Unit in MapController.map.get_units():
			a_star_grid.set_point_solid(
				unit.position / 16, not unit.faction.is_friend(_grid_current_faction)
			)


func _display_turn_change(faction: Faction) -> void:
	var phase_display := PhaseDisplay.instantiate(faction)
	MapController.get_ui().add_child(phase_display)
	await phase_display.tree_exited


func _get_dialogue() -> Dialogue:
	return MapController.get_ui().get_node("Dialogue") as Dialogue


func _next_faction() -> void:
	# Sets the faction to the next faction.
	_current_faction += 1
	if _current_faction == all_factions.size():
		_current_turn += 1
		_current_faction = 0


## Starts new turn.
func _start_turn() -> void:
	CursorController.cursor_visible = false
	CursorController.disable()
	await AudioPlayer.pause_track()

	await _display_turn_change(get_current_faction())
	# play banner
	if is_inside_tree():
		await get_tree().create_timer(0.25).timeout
	CursorController.enable()
	CursorController.cursor_visible = true
	if get_current_faction():
		AudioPlayer.play_track(get_current_faction().theme)
	if get_current_faction().player_type != Faction.PlayerTypes.HUMAN:
		end_turn.call_deferred()


func _toggle_full_outline() -> void:
	all_factions[_current_faction].full_outline = not (get_current_faction().full_outline)
	_update_outline()


func _toggle_outline_unit(unit: Unit) -> void:
	var outlined_units: Dictionary = get_current_faction().outlined_units
	if not (unit.faction in outlined_units):
		outlined_units[unit.faction] = []
	if unit in outlined_units[unit.faction]:
		(outlined_units[unit.faction] as Array).erase(unit)
	else:
		(outlined_units[unit.faction] as Array).append(unit)
	all_factions[_current_faction].outlined_units = outlined_units
	_update_outline()


func _update_outline() -> void:
	($MapLayer/Outline as Node2D).queue_redraw()
