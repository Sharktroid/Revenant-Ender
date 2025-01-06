## A Node that represents a map.
class_name Map
extends ReferenceRect

enum TileTypes { ATTACK, MOVEMENT, SUPPORT }
enum States { SELECTING, MOVING, CANTERING }

# Border boundaries of the map.
@export var _left_border: int
@export var _right_border: int
@export var _top_border: int
@export var _bottom_border: int
## The boundaries around the map. Units should not exceed these unless aesthetic
var borders: Rect2i
## An array that contains all of the factions currently being used.
var all_factions: Array[Faction]
var state: States = States.SELECTING:
	set(new_state):
		if state == States.CANTERING:
			if is_instance_valid(_canter_tiles):
				_canter_tiles.queue_free()
			_ghost_unit.queue_free()
		state = new_state
		match state:
			States.SELECTING:
				if _selected_unit.arrived.is_connected(_update_ghost_unit):
					_selected_unit.arrived.disconnect(_update_ghost_unit)
			States.CANTERING:
				var tiles: Array[Vector2i] = _selected_unit.get_movement_tiles()
				if tiles.size() > 1:
					_canter_tiles = MapController.map.display_tiles(
						tiles, Map.TileTypes.MOVEMENT, 1.0
					)
					_selected_unit.selected = true
					_selected_unit.hide_movement_tiles()
				else:
					state = States.SELECTING
					_selected_unit.wait()

# Movement costs for every movement type
var _movement_cost_dict: Dictionary
# The index of the current faction
var _current_faction_index: int = 0
# The [AStarGrids] that are used to generate movement paths
var _cost_grids: Dictionary = {}
# The faction that last used a grid.
var _grid_current_faction: Faction
# The current turn.
var _current_turn: int
var _selected_unit: Unit
var _ghost_unit: GhostUnit
var _ghost_unit_animation: Unit.Animations = Unit.Animations.IDLE
var _canter_tiles: Node2D
var _flags: Dictionary

# The terrain map layer
@onready var _terrain_layer := $MapLayer/TerrainLayer as TileMapLayer
# The visual map layer
@onready var _base_layer := $MapLayer/BaseLayer as TileMapLayer
# The border layer
@onready var _border_overlay := $MapLayer/DebugBorderOverlayContainer as CanvasGroup


func _init() -> void:
	_parse_movement_cost()


func _ready() -> void:
	CursorController.cursor_visible = false
	borders = Rect2i(_left_border * 16, _top_border * 16, 32, 32)
	borders = borders.expand(get_size() - Vector2(_right_border * 16, _bottom_border * 16))
	_create_debug_borders()  # Only shows up when collision shapes are enabled
	_update_terrain_display()
	DebugConfig.DISPLAY_MAP_TERRAIN.value_updated.connect(_update_terrain_display)
	_update_map_borders()
	DebugConfig.DISPLAY_MAP_BORDERS.value_updated.connect(_update_map_borders)
	_update_map_borders()
	DebugConfig.DISPLAY_MAP_CURSOR.value_updated.connect(_update_map_borders)

	var cell_max: Vector2i = _base_layer.get_used_cells().max()
	size = cell_max * 16 + Vector2i(16, 16)
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
	CursorController.disable()
	_start_turn()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		if CursorController.is_active():
			match state:
				States.SELECTING:
					_select_state_select()
				States.MOVING:
					_moving_state_select()
				States.CANTERING:
					_canter_state_select()
	elif event.is_action_pressed("back"):
		if state == States.MOVING:
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)
			_deselect()
	elif event.is_action_pressed("ranges"):
		if CursorController.get_hovered_unit():
			_toggle_outline_unit(CursorController.get_hovered_unit())
		else:
			_toggle_full_outline()
	elif event.is_action_pressed("status"):
		if CursorController.get_hovered_unit():
			create_status_screen()
	elif event.is_action_pressed("flag"):
		#print_debug(_flags.get(CursorController.map_position))
		if is_instance_valid(_flags.get(CursorController.map_position)):
			(_flags.get(CursorController.map_position) as Flag).queue_free()
		else:
			var flag: Flag = Flag.instantiate(CursorController.map_position)
			$MapLayer.add_child(flag)
			_flags[CursorController.map_position] = flag


func create_status_screen() -> void:
	AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_SELECT)
	var status_screen: StatusScreen = StatusScreen.instantiate(CursorController.get_hovered_unit())
	MapController.get_ui().add_child(status_screen)
	CursorController.disable()
	process_mode = ProcessMode.PROCESS_MODE_DISABLED
	await status_screen.tree_exited
	process_mode = ProcessMode.PROCESS_MODE_INHERIT


## A function that is called whenever a unit ends their turn.
func unit_wait(_unit: Unit) -> void:
	_update_outline()
	for unit: Unit in get_units():
		unit.reset_tile_cache()
	if (
		Options.AUTOEND_TURNS.value
		and _get_current_units().all(func(unit: Unit) -> bool: return unit.waiting)
	):
		end_turn.call_deferred()


## Gets the faction that is currently making their turn.
func get_current_faction() -> Faction:
	return all_factions[_current_faction_index]


## Gets the units that belong to the provided faction.
func get_faction_units(faction: Faction) -> Array[Unit]:
	return get_units().filter(func(unit: Unit) -> bool: return unit.faction == faction)


## Gets the next unit in the unit list relative to the given unit.
func get_next_unit(unit: Unit) -> Unit:
	return _get_unit_relative(unit, 1)


## Gets the previous unit in the unit list relative to the given unit.
func get_previous_unit(unit: Unit) -> Unit:
	return _get_unit_relative(unit, -1)


## Ends current turn.
func end_turn() -> void:
	# Have to wait a frame to avoid a race condition with MainMapMenu._exit_tree()
	await get_tree().physics_frame
	for unit: Unit in get_units():
		unit.awaken()
	_next_faction()
	_update_outline()
	CursorController.cursor_visible = false
	CursorController.disable()
	await AudioPlayer.pause_track()
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


## Displays an array of tile coordinates on the map.
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
		var get_alpha: Callable = func() -> float:
			return modulation if not ((i in modulate_blacklist) != blacklist_as_whitelist) else 1.0
		tiles_node.add_child(current_tile_base.instantiate(Vector2(i), get_alpha.call() as float))
	_base_layer.add_child(tiles_node)
	return tiles_node


## Displays tiles while highlighting tiles where a unit currently is.
func display_highlighted_tiles(tiles: Array[Vector2i], unit: Unit, type: TileTypes) -> Node2D:
	var unit_coords: Array[Vector2i] = []
	var enemy_units: Array[Unit] = get_units().filter(
		func(e_unit: Unit) -> bool: return not (unit.is_friend(e_unit)) and e_unit.visible
	)
	unit_coords.assign(
		enemy_units.map(func(e_unit: Unit) -> Vector2i: return Vector2i(e_unit.position))
	)
	return display_tiles(tiles, type, 0.5, unit_coords)


## Gets the movement path to navigate from the starting point to the destination.
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
	if (
		movement_grid.is_in_boundsv(starting_point / 16)
		and movement_grid.is_in_boundsv(destination / 16)
	):
		var raw_path: Array = movement_grid.get_point_path(starting_point / 16, destination / 16)
		var output: Array[Vector2i] = []
		output.assign(raw_path.map(func(vector: Vector2) -> Vector2i: return vector * 16))
		return output
	else:
		return []


## Gets the cost of traversing a movement path.
func get_path_cost(movement_type: UnitClass.MovementTypes, path: Array[Vector2i]) -> float:
	if path.is_empty():
		return INF
	path.remove_at(0)
	var sum: Callable = func(accumulator: float, cell: Vector2i) -> float:
		return accumulator + get_terrain_cost(movement_type, cell)
	return path.reduce(sum, 0)


## Gets all units.
func get_units() -> Array[Unit]:
	if is_inside_tree():
		var units: Array[Unit] = []
		units.assign(get_tree().get_nodes_in_group("unit"))
		return units
	return []


## Updates the terrain cost at a position.
func update_position_terrain_cost(pos: Vector2i) -> void:
	for movement_type: UnitClass.MovementTypes in _cost_grids.keys():
		var a_star_grid: AStarGrid2D = _cost_grids[movement_type]
		var point_id: Vector2i = pos / 16
		_update_a_star_grid_id(a_star_grid, movement_type, point_id)
		a_star_grid.set_point_solid(point_id, false)
	if get_units().any(func(unit: Unit) -> bool: return unit.position == Vector2(pos)):
		_update_grid_current_faction()


## Returns the [Map]'s [MapCamera].
func get_map_camera() -> MapCamera:
	var path: String = NodePath("%s/MapCamera" % get_path())
	return (get_node(path) as MapCamera) if has_node(path) else MapCamera.new()


## Returns true if the faction is friendly to a human.
func is_faction_friendly_to_human(faction: Faction) -> bool:
	var is_human_friend: Callable = func(human_faction: Faction) -> bool:
		return (
			human_faction.player_type == Faction.PlayerTypes.HUMAN
			and faction.is_friend(human_faction)
		)
	return all_factions.any(is_human_friend)


# Updates AStarGrid2D
func _update_a_star_grid_id(
	a_star_grid: AStarGrid2D, movement_type: UnitClass.MovementTypes, id: Vector2i
) -> void:
	var weight: float = get_terrain_cost(movement_type, id * 16)
	if weight == INF:
		a_star_grid.set_point_solid(id)
	else:
		a_star_grid.set_point_weight_scale(id, weight)


func _intro() -> void:
	await get_tree().process_frame


func _get_terrain(coords: Vector2i) -> String:
	## Gets the name of the terrain at the tile at position "coords"
	if not borders.has_point(coords):
		return "Blocked"
	else:
		return _terrain_layer.get_cell_tile_data(coords / 16).get_custom_data("TerrainName")


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
		var type: UnitClass.MovementTypes = UnitClass.MovementTypes[
			(split.pop_at(0) as String).to_snake_case().to_upper()
		]
		_movement_cost_dict[type] = {}
		for cost: int in split.size():
			_movement_cost_dict[type][header[cost]] = split[cost]


func _get_unit_relative(unit: Unit, rel_index: int) -> Unit:
	var faction_units: Array[Unit] = get_faction_units(unit.faction)
	return faction_units[(faction_units.find(unit) + rel_index) % faction_units.size()]


func _moving_state_select() -> void:
	if _selected_unit.faction.name == get_current_faction().name:
		var items: Array[bool] = []
		items.assign(UnitMenu.get_displayed_items(_selected_unit).values())
		if (
			CursorController.map_position in _selected_unit.get_movement_tiles()
			and items.any(func(value: bool) -> bool: return value)
		):
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_SELECT)
			var menu := UnitMenu.instantiate(
				CursorController.screen_position + Vector2i(16, 0), null, _selected_unit
			)
			CursorController.disable()
			process_mode = ProcessMode.PROCESS_MODE_DISABLED
			MapController.get_ui().add_child(menu)
			await menu.tree_exited
			process_mode = ProcessMode.PROCESS_MODE_INHERIT
		elif (
			CursorController.get_hovered_unit()
			and CursorController.map_position in _selected_unit.get_all_attack_tiles()
		):
			_attack_selection()

		else:
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.INVALID)
	else:
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)


func _attack_selection() -> void:
	CursorController.disable()
	CursorController.cursor_visible = false
	_selected_unit.hide_movement_tiles()
	AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_SELECT)
	var info_display := CombatInfoDisplay.instantiate(
		_selected_unit, CursorController.get_hovered_unit(), true
	)
	MapController.get_ui().add_child(info_display)
	_selected_unit.display_current_attack_tiles()
	set_process_input(false)
	var completed: bool = await info_display.completed
	_selected_unit.hide_current_attack_tiles()
	info_display.queue_free()
	if completed:
		await _selected_unit.move()
		await AttackController.combat(_selected_unit, CursorController.get_hovered_unit())
		_selected_unit.wait()
		_deselect()
	else:
		_selected_unit.display_movement_tiles()
		get_tree().root.set_input_as_handled()
		state = States.MOVING
	CursorController.enable()
	CursorController.cursor_visible = true
	set_process_input(true)


func _canter_state_select() -> void:
	if CursorController.map_position in _selected_unit.get_actionable_movement_tiles():
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_SELECT)
		const CanterMenu = preload("res://ui/map_ui/map_menus/canter_menu/canter_menu.gd")
		CursorController.disable()
		var menu_position: Vector2i = CursorController.screen_position + Vector2i(16, -8)
		MapController.get_ui().add_child(
			CanterMenu.instantiate(menu_position, null, _selected_unit)
		)
		_ghost_unit.visible = true


func _select_state_select() -> void:
	var hovered_unit: Unit = CursorController.get_hovered_unit()
	if hovered_unit and hovered_unit.selectable and not hovered_unit.waiting:
		AudioPlayer.play_sound_effect(preload("res://audio/sfx/double_select.ogg"))
		_selected_unit = hovered_unit
		state = States.MOVING
		_selected_unit.set_animation(Unit.Animations.MOVING_LEFT)
		_selected_unit.selected = true
		_selected_unit.update_path(CursorController.map_position)
		_selected_unit.update_displayed_tiles()
		_selected_unit.display_movement_tiles()
		_ghost_unit = GhostUnit.new(_selected_unit)
		_ghost_unit.position = CursorController.map_position
		MapController.map.get_child(0).add_child(_ghost_unit)
		var on_cursor_moved: Callable = func() -> void:
			if process_mode != ProcessMode.PROCESS_MODE_DISABLED and state != States.SELECTING:
				_selected_unit.update_path(CursorController.map_position)
				_selected_unit.show_path()
				_ghost_unit.position = _selected_unit.get_path_last_pos()
				_update_ghost_unit()
		CursorController.moved.connect(on_cursor_moved)
		_selected_unit.arrived.connect(_update_ghost_unit)
		_update_ghost_unit()
		_selected_unit.z_index = 1
	else:
		AudioPlayer.play_sound_effect(preload("res://audio/sfx/menu_open.ogg"))
		const MainMapMenu = preload("res://ui/map_ui/map_menus/main_map_menu/main_map_menu.gd")
		var menu := MainMapMenu.instantiate(CursorController.screen_position + Vector2i(16, 0))
		MapController.get_ui().add_child(menu)
		CursorController.disable()


func _update_ghost_unit() -> void:
	_ghost_unit.visible = _ghost_unit.position != _selected_unit.position
	if _ghost_unit.visible == true:
		var distance := Vector2i()
		if _selected_unit.get_unit_path().size() >= 2:
			distance = _selected_unit.get_unit_path()[-1] - _selected_unit.get_unit_path()[-2]
		var next_animation: Unit.Animations
		match distance:
			Vector2i(16, 0):
				next_animation = Unit.Animations.MOVING_RIGHT
			Vector2i(-16, 0):
				next_animation = Unit.Animations.MOVING_LEFT
			Vector2i(0, -16):
				next_animation = Unit.Animations.MOVING_UP
			_:
				next_animation = Unit.Animations.MOVING_DOWN
		if _ghost_unit_animation != next_animation:
			_ghost_unit.set_animation(next_animation)
			_ghost_unit_animation = next_animation


func _update_grid_current_faction() -> void:
	for movement_type: UnitClass.MovementTypes in _cost_grids.keys():
		for unit: Unit in get_units():
			(_cost_grids[movement_type] as AStarGrid2D).set_point_solid(
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
	_current_faction_index += 1
	if _current_faction_index == all_factions.size():
		_current_turn += 1
		_current_faction_index = 0


## Starts new turn.
func _start_turn() -> void:
	await _display_turn_change(get_current_faction())
	if (
		not Options.SMART_CURSOR.value
		and GameController.controller_type == GameController.ControllerTypes.KEYBOARD
	):
		CursorController.map_position = _get_current_units()[0].position
	# play banner
	if is_inside_tree():
		await get_tree().create_timer(0.25).timeout
	if get_current_faction().player_type == Faction.PlayerTypes.HUMAN:
		CursorController.enable()
		CursorController.cursor_visible = true
	if get_current_faction():
		AudioPlayer.play_track(get_current_faction().theme)
	if get_current_faction().player_type != Faction.PlayerTypes.HUMAN:
		end_turn.call_deferred()


func _toggle_full_outline() -> void:
	all_factions[_current_faction_index].full_outline = not (get_current_faction().full_outline)
	_update_outline()


func _toggle_outline_unit(unit: Unit) -> void:
	var outlined_units: Dictionary = get_current_faction().outlined_units
	if not (unit.faction in outlined_units):
		outlined_units[unit.faction] = []
	if unit in outlined_units[unit.faction]:
		(outlined_units[unit.faction] as Array).erase(unit)
	else:
		(outlined_units[unit.faction] as Array).append(unit)
	all_factions[_current_faction_index].outlined_units = outlined_units
	_update_outline()


func _update_outline() -> void:
	($MapLayer/Outline as Node2D).queue_redraw()


# Updates whether the terrain display is on
func _update_terrain_display() -> void:
	_terrain_layer.visible = DebugConfig.DISPLAY_MAP_TERRAIN.value


# Updates whether map borders are displayed
func _update_map_borders() -> void:
	_border_overlay.visible = DebugConfig.DISPLAY_MAP_BORDERS.value


# Gets the units of the current faction
func _get_current_units() -> Array[Unit]:
	return get_faction_units(get_current_faction())


func _deselect() -> void:
	state = States.SELECTING
	_ghost_unit.queue_free()
	var hovered_unit: Unit = CursorController.get_hovered_unit()
	if hovered_unit and hovered_unit != _selected_unit and not hovered_unit.dead:
		hovered_unit.display_movement_tiles()
	if is_instance_valid(_selected_unit):
		_selected_unit.deselect()
		_selected_unit.z_index = 0
