## An Autoload that handles the position of the cursor and displaying it.
extends Node

signal moved

## Icons that can be displayed.
enum Icons { ATTACK, NONE }

## Whether the cursor is being displayed.
var cursor_visible: bool = true:
	get:
		return cursor_visible and not _offscreen
## The position of the cursor relative to the map's origin.
var map_position := Vector2i():
	set = set_map_position
## The position of the cursor relative to the top-left corner of the screen.
var screen_position: Vector2i:
	set(value):
		map_position = value + _corner_offset()
	get:
		return map_position - _corner_offset()
var fast_cursor: bool = false:
	set = set_fast_cursor

var _active: bool = true
var _offscreen: bool = false
var _buffered_position: Vector2i
var _slow_cursor_controller := TwoAxisInputController.new(
	_scroll.bind(1.0/15), &"left", &"right", &"up", &"down", 0.25 - 1.0/15, 0
)
var _fast_cursor_controller := TwoAxisInputController.new(
	_scroll.bind(1.0/60), &"left", &"right", &"up", &"down", 0, 0
)
var _cursor_speed: float = INF


func _init() -> void:
	set_process_input(true)


func _ready() -> void:
	if Utilities.is_running_project():
		set_icon(Icons.NONE)
		add_child(_slow_cursor_controller)
		add_child(_fast_cursor_controller)
		fast_cursor = false
	else:
		queue_free()


func _physics_process(_delta: float) -> void:
	if MapController.map:
		if _active and GameController.controller_type == GameController.ControllerTypes.MOUSE:
			_offscreen = not MapController.map.borders.has_point(
				MapController.map.get_local_mouse_position()
			)
			get_area().monitorable = is_active()
			get_area().monitoring = is_active()
		if is_active():
			if GameController.controller_type == GameController.ControllerTypes.MOUSE:
				var destination: Vector2 = MapController.map.get_map_camera().get_destination()
				if destination == MapController.map.get_map_camera().position:
					map_position = Utilities.round_coords_to_tile(
						get_viewport().get_mouse_position() + (_corner_offset() as Vector2)
					)


func _input(_event: InputEvent) -> void:
	if GameController.controller_type == GameController.ControllerTypes.KEYBOARD:
		_offscreen = false
	if _event.is_action(&"fast_cursor"):
		fast_cursor = _event.is_pressed()


## Enables movement of the cursor.
func enable() -> void:
	set_active(true)


## Disables movement of the cursor.
func disable() -> void:
	set_active(false)


func set_icon(icon: Icons) -> void:
	var icon_sprite := MapController.get_ui().get_node("Cursor/Icon") as Sprite2D
	if icon == Icons.NONE:
		icon_sprite.visible = false
	else:
		icon_sprite.visible = true
		match icon:
			Icons.ATTACK:
				icon_sprite.texture = preload("res://cursor/attack.png")
				icon_sprite.position = Vector2i(0, -16)


## Gets the [Area2D] hitbox for the cursor.
func get_area() -> Area2D:
	var path := NodePath("%s/MapLayer/CursorArea" % MapController.map.get_path())
	return get_node(path) if has_node(path) else Area2D.new()


## Returns true if cursor movement is active.
func is_active() -> bool:
	return _active and not _offscreen


## Returns the unit currently underneath the cursor.
func get_hovered_unit() -> Unit:
	var filter: Callable = func(unit: Unit) -> bool:
		return unit.position.round() as Vector2i == map_position and unit.visible
	var units: Array[Unit] = MapController.map.get_units().filter(filter)
	return units.front() if not units.is_empty() else null


## Sets cursor position relative to the map
func set_map_position(new_pos: Vector2i) -> void:
	var old_pos: Vector2i = map_position
	map_position = new_pos.clamp(
		MapController.map.borders.position, MapController.map.borders.end - Vector2i(16, 16)
	)
	_buffered_position = map_position
	var map_move := Vector2i()
	for i: int in 2:
		while screen_position[i] - map_move[i] < 16:
			map_move[i] -= 16
		while screen_position[i] - map_move[i] >= Utilities.get_screen_size()[i] - 16:
			map_move[i] += 16
	if map_move != Vector2i():
		MapController.map.get_map_camera().move(map_move)
	if map_position != old_pos:
		var emit_moved: Callable = func() -> void: moved.emit()
		emit_moved.call_deferred()

## Sets whether the cursor is on fast mode or not.
func set_fast_cursor(on: bool) -> void:
	fast_cursor = on
	_slow_cursor_controller.process_mode = (
		Node.PROCESS_MODE_DISABLED if fast_cursor else Node.PROCESS_MODE_INHERIT
	)
	_fast_cursor_controller.process_mode = (
		Node.PROCESS_MODE_INHERIT if fast_cursor else Node.PROCESS_MODE_DISABLED
	)


## Gets the speed of the cursor in pixels per second
func get_cursor_speed() -> float:
	return _cursor_speed


func set_active(active: bool) -> void:
	_active = active
	process_mode = Node.PROCESS_MODE_ALWAYS if active else Node.PROCESS_MODE_DISABLED


func _scroll(new_position: Vector2, duration: float) -> void:
	var old_position: Vector2 = map_position
	map_position += Vector2i(new_position.ceil() * 16)
	AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.CURSOR)
	_cursor_speed = Utilities.get_tile_distance(map_position, old_position) * 16 / duration
	await get_tree().create_timer(duration).timeout
	_cursor_speed = INF


func _corner_offset() -> Vector2i:
	if MapController.map:
		return (
			Vector2i(MapController.map.get_map_camera().get_map_position())
			+ MapController.map.get_map_camera().get_map_offset()
		)
	return Vector2i.ZERO
