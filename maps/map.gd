## A Node that represents a map.
@abstract class_name Map
extends ReferenceRect

enum TileTypes { ATTACK, MOVEMENT, SUPPORT, WARP }
enum States { SELECTING, MOVING, CANTERING }

const _SAVED_PROPERTY_NAMES: Array[StringName] = [
	&"all_factions", &"_current_faction_index", &"_current_turn", &"_flags"
]

# Border boundaries of the map.
@export var _left_border: int
@export var _right_border: int
@export var _top_border: int
@export var _bottom_border: int
## The boundaries around the map. Units should not exceed these unless aesthetic
var borders: Rect2i
## An array that contains all of the factions currently being used.
var all_factions: Array[Faction]
# FIXME: The implementation of this shouldn't go beyond the scope of this class. Look into unit_wait.
## The current state. Controls input.
var state: States = States.SELECTING:
	set = set_state

var _group_keys: Array[Key] = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0]
var _keys_dictionary: Dictionary[Key, int] = {}
var _group_modifiers: Array[Key] = [KEY_SHIFT, KEY_ALT]
# Movement costs for every movement type
var _movement_cost_dict: Dictionary[UnitClass.MovementTypes, Dictionary]
# The index of the current faction
var _current_faction_index: int = 0
# The [AStarGrids] that are used to generate movement paths
var _cost_grids: Dictionary[UnitClass.MovementTypes, AStarGrid2D] = {}
# The faction that last used a grid.
var _grid_current_faction: Faction
# The current turn.
var _current_turn: int = 1
var _selected_unit: Unit
var _ghost_unit: UnitSprite
var _canter_tiles: Node2D
var _flags: Dictionary[Vector2i, Flag]
var _rewind: Array[Dictionary]
var _shortcut_units: Dictionary[int, Unit] = {}
var _info_display: CombatPanel

# The terrain map layer
@onready var _terrain_layer := $MapLayer/TerrainLayer as TileMapLayer
# The visual map layer
@onready var _base_layer := $MapLayer/BaseLayer as TileMapLayer
# The border layer
@onready var _border_overlay := $MapLayer/DebugBorderOverlayContainer as CanvasGroup


func _init() -> void:
	_parse_movement_cost()


func _ready() -> void:
	for key_index: int in _group_keys.size():
		_keys_dictionary[_group_keys[key_index]] = key_index
		var input_event := InputEventKey.new()
		input_event.keycode = _group_keys[key_index]
		var action_name: StringName = "group_%s" % (key_index + 1)
		InputMap.action_add_event(&"control_group", input_event)
		InputMap.add_action(action_name)
		InputMap.action_add_event(action_name, input_event)
	CursorController.cursor_visible = false
	borders = Rect2i(_left_border * 16, _top_border * 16, 32, 32)
	borders = borders.expand(get_size() - Vector2(_right_border * 16, _bottom_border * 16))
	_create_debug_borders()  # Only shows up when collision shapes are enabled
	_update_terrain_display()
	Options.DISPLAY_MAP_TERRAIN.value_updated.connect(_update_terrain_display)
	_update_map_borders()
	Options.DISPLAY_MAP_BORDERS.value_updated.connect(_update_map_borders)
	_update_map_borders()
	Options.DISPLAY_MAP_CURSOR.value_updated.connect(_update_map_borders)

	var cell_max: Vector2i = _base_layer.get_used_cells().max()
	size = cell_max * 16 + Vector2i(16, 16)
	for movement_type: UnitClass.MovementTypes in (
		_movement_cost_dict.keys() as Array[UnitClass.MovementTypes]
	):
		_cost_grids[movement_type] = _get_a_star_grid(cell_max, movement_type)
	await _intro()
	if not MapController.get_ui().is_node_ready():
		await MapController.get_ui().ready
	CursorController.disable()
	_start_turn()
	CursorController.moved.connect(_on_cursor_moved)

	for unit in get_units():
		unit.turn_ended.connect(func(action: String) -> void: _unit_wait(unit, action))


func _process(_delta: float) -> void:
	if state == States.MOVING and CursorController.is_active():
		if (
			CursorController.get_hovered_unit()
			and not _selected_unit.is_friend(CursorController.get_hovered_unit())
		):
			CursorController.set_icon(CursorController.Icons.ATTACK)
		else:
			CursorController.set_icon(CursorController.Icons.NONE)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"select"):
		if CursorController.is_active():
			match state:
				States.SELECTING:
					_select_state_select()
				States.MOVING:
					_moving_state_select()
				States.CANTERING:
					_canter_state_select()
	elif event.is_action_pressed(&"back"):
		if state == States.MOVING:
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)
			_deselect()
	elif event.is_action_pressed(&"ranges"):
		if CursorController.get_hovered_unit():
			_toggle_outline_unit(CursorController.get_hovered_unit())
		else:
			_toggle_full_outline()
	elif event.is_action_pressed(&"status"):
		if CursorController.get_hovered_unit():
			_create_status_screen()
	elif event.is_action_pressed(&"flag"):
		if is_instance_valid(_flags.get(CursorController.map_position)):
			(_flags.get(CursorController.map_position) as Flag).queue_free()
		else:
			var flag: Flag = Flag.instantiate(CursorController.map_position)
			$MapLayer.add_child(flag)
			_flags[CursorController.map_position] = flag
	if event.is_action_pressed(&"rewind"):
		process_mode = Node.PROCESS_MODE_DISABLED
		CursorController.disable()
		CursorController.cursor_visible = false
		var rewind_menu := RewindMenu.instantiate(_rewind)
		MapController.get_ui().add_child(rewind_menu)
		await rewind_menu.tree_exited
		CursorController.enable()
		CursorController.cursor_visible = true
		process_mode = Node.PROCESS_MODE_INHERIT
		if get_current_faction().player_type != Faction.PlayerTypes.HUMAN:
			end_turn.call_deferred()
	elif event.is_action_pressed(&"control_group", true) and event is InputEventKey:
		if Input.is_action_pressed(&"group_modifier_set"):
			if CursorController.get_hovered_unit():
				_shortcut_units[_get_control_group(event as InputEventKey)] = (
					CursorController.get_hovered_unit()
				)
		else:
			if _shortcut_units.has(_get_control_group(event as InputEventKey)):
				CursorController.map_position = (
					_shortcut_units[_get_control_group(event as InputEventKey)].position
				)
				var pixel_scale: Vector2 = (
					Vector2(DisplayServer.window_get_size()) / Vector2(Utilities.get_screen_size())
				)
				Input.warp_mouse(
					Vector2(CursorController.screen_position + (Vector2i.ONE * 8)) * pixel_scale
				)


## Gets the faction that is currently making their turn.
func get_current_faction() -> Faction:
	return all_factions[_current_faction_index]


## Gets the next unit in the unit list relative to the given unit.
func get_next_unit(unit: Unit) -> Unit:
	return get_unit_relative(unit, 1)


## Gets the previous unit in the unit list relative to the given unit.
func get_previous_unit(unit: Unit) -> Unit:
	return get_unit_relative(unit, -1)


## Ends current turn.
func end_turn() -> void:
	# Have to wait a frame to avoid a race condition with MainMapMenu._exit_tree()
	# TODO: See if there's a more elegant way to eliminate the race con; document the race con.
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
	if _movement_cost_dict.has(movement_type):
		var movement_type_terrain_dict: Dictionary[String, String] = {}
		movement_type_terrain_dict.assign(_movement_cost_dict[movement_type])
		var terrain_name: String = _get_terrain(coords)
		# Combines several terrain names for compactness.
		match terrain_name:
			"HQ", "Factory", "City", "House", "Gate", "Village":
				terrain_name = "Road"
			"Sea":
				terrain_name = "Ocean"
		if movement_type_terrain_dict.has(terrain_name):
			var cost: String = movement_type_terrain_dict[terrain_name]
			if cost.is_valid_float():
				return float(cost)
			elif cost == "N/A":
				return INF
			push_error('Terrain cost "%s" is invalid' % cost)
		else:
			push_error('Terrain "%s" is invalid' % terrain_name)
	else:
		push_error('Movement type "%s" is invalid' % movement_type)
	return INF


# TODO: Maybe this can be per-unit and stae.
## Displays an array of tile coordinates on the map.
func display_tiles(
	tiles: Set,
	type: TileTypes,
	modulation: float = 0.5,
	modulate_blacklist := Set.new(),
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
		TileTypes.WARP:
			current_tile_base = preload("res://maps/map_tiles/warp_tile.gd")
	for i: Vector2i in tiles:
		var get_alpha: Callable = func() -> float:
			return modulation if not (modulate_blacklist.has(i) != blacklist_as_whitelist) else 1.0
		tiles_node.add_child(current_tile_base.instantiate(Vector2(i), get_alpha.call() as float))
	_base_layer.add_child(tiles_node)
	return tiles_node


# TODO: merge with the one above.
## Displays tiles while highlighting tiles where a unit currently is.
func display_highlighted_tiles(tiles: Set, unit: Unit, type: TileTypes) -> Node2D:
	var unit_coords: Array[Vector2i] = []
	var enemy_units: Array[Unit] = get_units().filter(
		func(e_unit: Unit) -> bool: return not (unit.is_friend(e_unit)) and e_unit.visible
	)
	unit_coords.assign(
		enemy_units.map(func(e_unit: Unit) -> Vector2i: return Vector2i(e_unit.position))
	)
	return display_tiles(tiles, type, 0.5, Set.new(unit_coords))


# TODO: Might be worth making this threaded.
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
		units.assign(get_tree().get_nodes_in_group(&"units"))
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


func set_state(new_state: States) -> void:
	if state == States.CANTERING:
		if is_instance_valid(_canter_tiles):
			_canter_tiles.queue_free()
		_ghost_unit.queue_free()
	elif state == States.MOVING:
		_reset_attack_colors()
	state = new_state
	match state:
		States.SELECTING:
			if is_instance_valid(_ghost_unit):
				_ghost_unit.queue_free()
			if _selected_unit and _selected_unit.arrived.is_connected(_update_ghost_unit):
				_selected_unit.arrived.disconnect(_update_ghost_unit)
		States.CANTERING:
			var tiles: Set = _selected_unit.get_movement_tiles()
			if tiles.size() > 1:
				_canter_tiles = MapController.map.display_tiles(tiles, Map.TileTypes.MOVEMENT, 1.0)
				_selected_unit.selected = true
				_selected_unit.hide_movement_tiles()
			else:
				state = States.SELECTING
				_selected_unit.wait()
		States.MOVING:
			_apply_attack_colors()


## Saves the current state of the map. Faster than PackedScene.pack().
func quick_save(action_name: String, unit_sprite: UnitSprite = null) -> void:
	var properties: Dictionary[StringName, Variant] = {}
	for property_name: String in _SAVED_PROPERTY_NAMES:
		properties[property_name] = get(property_name)
	var units: Dictionary[String, Dictionary] = {}
	for unit: Unit in get_units():
		units[unit.name] = unit.quick_save()
	properties[&"units"] = units
	properties[&"name"] = action_name
	properties[&"unit_sprite"] = unit_sprite
	properties[&"current_faction"] = get_current_faction()
	# 10000 of these takes up ~302 MB
	_rewind.append(properties)


## Loads a dictionary returned from quick_save.
func quick_load(properties: Dictionary[StringName, Variant]) -> void:
	for property_name: StringName in _SAVED_PROPERTY_NAMES:
		set(property_name, properties[property_name])
	var units := (properties[&"units"] as Dictionary).duplicate() as Dictionary[String, Dictionary]
	for unit: Unit in get_units():
		if units.has(unit.name) and not units[unit.name][&"dead"]:
			unit.quick_load(units[unit.name])
			units.erase(unit.name)
		else:
			unit.queue_free()
	for unit_name: StringName in units.keys():
		if not units[unit_name][&"dead"]:
			var new_unit := Unit.full_load(units[unit_name], %Units)
			new_unit.name = unit_name


func rewind_load(index: int, delete_newer: bool = false) -> void:
	quick_load(_rewind[index])
	if delete_newer:
		_rewind = _rewind.slice(0, index + 1)


func get_unit_relative(unit: Unit, rel_index: int) -> Unit:
	var faction_units: Array[Unit] = unit.faction.get_units()
	return faction_units[(faction_units.find(unit) + rel_index) % faction_units.size()]


## Shows the status screen for the unit the cursor is hovering over.
func _create_status_screen() -> void:
	AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_SELECT)
	var status_screen: StatusScreen = StatusScreen.instantiate(CursorController.get_hovered_unit())
	MapController.get_ui().add_child(status_screen)
	CursorController.disable()
	process_mode = PROCESS_MODE_DISABLED
	await status_screen.tree_exited
	process_mode = PROCESS_MODE_INHERIT


## A function that is called whenever a unit ends their turn.
func _unit_wait(unit: Unit, action_name: String) -> void:
	_update_outline()
	for map_unit: Unit in get_units():
		map_unit.reset_tile_cache()
	if (
		Options.AUTOEND_TURNS.value
		and _get_current_units().all(func(current_unit: Unit) -> bool: return current_unit.waiting)
	):
		end_turn.call_deferred()
	quick_save(
		"{unit} {action}".format({"unit": unit.display_name, "action": action_name}),
		unit.get_sprite()
	)


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


func _get_control_group(event: InputEventKey) -> int:
	var value: int = _keys_dictionary[event.keycode] + 1
	for modifier_index: int in _group_modifiers.size():
		if Input.is_key_pressed(_group_modifiers[modifier_index]):
			value += _group_keys.size() * (modifier_index + 1)
	return value


func _moving_state_select() -> void:
	if _selected_unit.faction.name == get_current_faction().name:
		var items: Array[bool] = []
		items.assign(UnitMenu.get_displayed_items(_selected_unit).values())
		if (
			_selected_unit.get_actionable_movement_tiles().has(CursorController.map_position)
			and items.any(func(value: bool) -> bool: return value)
		):
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_SELECT)
			var menu := UnitMenu.instantiate(
				CursorController.screen_position + Vector2i(16, 0), null, _selected_unit
			)
			_reset_attack_colors()
			CursorController.disable()
			process_mode = PROCESS_MODE_DISABLED
			MapController.get_ui().add_child(menu)
			await menu.tree_exited
			process_mode = PROCESS_MODE_INHERIT
			_apply_attack_colors()
		elif (
			CursorController.get_hovered_unit()
			and _selected_unit.get_all_attack_tiles().has(CursorController.map_position)
		):
			_attack_selection()

		else:
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.INVALID)
	else:
		AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)


func _attack_selection() -> void:
	_reset_attack_colors()
	CursorController.disable()
	_selected_unit.hide_movement_tiles()
	AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.MENU_SELECT)
	_info_display = CombatPanel.instantiate(
		_selected_unit,
		_on_attack_confirmation.bind(true),
		_on_attack_confirmation.bind(false),
		CursorController.get_hovered_unit(),
		true
	)
	MapController.get_ui().add_child(_info_display)
	_selected_unit.display_current_attack_tiles()
	set_process_input(false)


func _on_attack_confirmation(completed: bool) -> void:
	_selected_unit.hide_current_attack_tiles()
	var combat_art: CombatArt = _info_display.get_combat_art()
	_info_display.queue_free()
	if completed:
		CursorController.set_icon(CursorController.Icons.NONE)
		await _selected_unit.move()
		await AttackController.play_combat_animation(_selected_unit, CursorController.get_hovered_unit(), combat_art)
		_selected_unit.wait()
		_deselect()
	else:
		_selected_unit.display_movement_tiles()
		get_tree().root.set_input_as_handled()
		state = States.MOVING
		CursorController.enable()
	set_process_input(true)


func _canter_state_select() -> void:
	if _selected_unit.get_actionable_movement_tiles().has(CursorController.map_position):
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
		if _ghost_unit:
			_ghost_unit.queue_free()
		_ghost_unit = _selected_unit.get_sprite()
		_ghost_unit.name = "Ghost Unit"
		_ghost_unit.modulate.a = 0.5
		_ghost_unit.position = CursorController.map_position
		MapController.map.get_child(0).add_child(_ghost_unit)
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
		var next_animation: UnitSprite.Animations
		match distance:
			Vector2i(16, 0):
				next_animation = UnitSprite.Animations.MOVING_RIGHT
			Vector2i(-16, 0):
				next_animation = UnitSprite.Animations.MOVING_LEFT
			Vector2i(0, -16):
				next_animation = UnitSprite.Animations.MOVING_UP
			_:
				next_animation = UnitSprite.Animations.MOVING_DOWN
		_ghost_unit.set_animation(next_animation)


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
	quick_save("Start of turn")
	await _display_turn_change(get_current_faction())
	if not Options.SMART_CURSOR.value and not _get_current_units().is_empty():
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
	var outlined_units: Dictionary[Faction, Array] = get_current_faction().outlined_units
	if not outlined_units.has(unit.faction):
		outlined_units[unit.faction] = []
	if outlined_units[unit.faction].has(unit):
		outlined_units[unit.faction].erase(unit)
	else:
		outlined_units[unit.faction].append(unit)
	all_factions[_current_faction_index].outlined_units = outlined_units
	_update_outline()


func _update_outline() -> void:
	($MapLayer/Outline as Node2D).queue_redraw()


# Updates whether the terrain display is on
func _update_terrain_display() -> void:
	_terrain_layer.visible = Options.DISPLAY_MAP_TERRAIN.value


# Updates whether map borders are displayed
func _update_map_borders() -> void:
	_border_overlay.visible = Options.DISPLAY_MAP_BORDERS.value


# Gets the units of the current faction
func _get_current_units() -> Array[Unit]:
	return get_current_faction().get_units()


func _deselect() -> void:
	state = States.SELECTING
	_ghost_unit.queue_free()
	var hovered_unit: Unit = CursorController.get_hovered_unit()
	if hovered_unit and hovered_unit != _selected_unit and not hovered_unit.dead:
		hovered_unit.display_movement_tiles()
	if is_instance_valid(_selected_unit):
		_selected_unit.deselect()
		_selected_unit.z_index = 0
		if (
			Options.CURSOR_RETURN.value
			and GameController.controller_type == GameController.ControllerTypes.KEYBOARD
		):
			CursorController.map_position = _selected_unit.position


func _get_a_star_grid(cell_max: Vector2i, movement_type: UnitClass.MovementTypes) -> AStarGrid2D:
	var a_star_grid := AStarGrid2D.new()
	a_star_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star_grid.region = Rect2i(Vector2i(0, 0), cell_max + Vector2i(1, 1))
	a_star_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	a_star_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	a_star_grid.jumping_enabled = false
	a_star_grid.update()
	for cell: Vector2i in _base_layer.get_used_cells():
		_update_a_star_grid_id(a_star_grid, movement_type, cell)
	return a_star_grid


func _run_script(script_name: StringName) -> void:
	CursorController.disable()
	await _get_dialogue().parse_script(script_name, self)
	CursorController.enable()


func _on_cursor_moved() -> void:
	if can_process() and state != States.SELECTING:
		_selected_unit.update_path(CursorController.map_position)
		_selected_unit.show_path()
		_ghost_unit.position = _selected_unit.get_path_last_pos()
		_update_ghost_unit()
		_apply_attack_colors()


func _apply_attack_colors() -> void:
	for unit: Unit in get_units().filter(
		func(unit: Unit) -> bool: return not unit.is_friend(_selected_unit)
	):
		if unit.get_all_attack_tiles().has(_selected_unit.get_path_last_pos()):
			unit.modulate = Color.RED
			unit.modulate.s = 0.5
		else:
			unit.modulate = Color.WHITE


func _reset_attack_colors() -> void:
	for unit: Unit in get_units().filter(
		func(unit: Unit) -> bool: return not unit.is_friend(_selected_unit)
	):
		unit.modulate = Color.WHITE
