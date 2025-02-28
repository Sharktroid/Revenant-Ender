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

var _active: bool = true
var _delay: int = 0
var _repeat: bool = false
var _offscreen: bool = false


func _init() -> void:
	set_process_input(true)


func _ready() -> void:
	if Utilities.is_running_project():
		set_icon(Icons.NONE)
	else:
		queue_free()


func _physics_process(_delta: float) -> void:
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
		else:
			_offscreen = false
			if _delay <= 0 and _repeat:
				if (
					Input.is_action_pressed("left")
					or Input.is_action_pressed("right")
					or Input.is_action_pressed("up")
					or Input.is_action_pressed("down")
				):
					var old_pos: Vector2i = map_position
					map_position = _get_new_position()
					if map_position != old_pos:
						AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.CURSOR)
					_delay = 4
				else:
					_repeat = false
	_delay -= 1


func _input(event: InputEvent) -> void:
	if GameController.controller_type == GameController.ControllerTypes.KEYBOARD:
		_offscreen = false
	if is_active():
		var new_pos: Vector2i = map_position
		if event.is_action_pressed("left") and not Input.is_action_pressed("right"):
			new_pos.x -= 16
		elif event.is_action_pressed("right"):
			new_pos.x += 16
		if event.is_action_pressed("up") and not Input.is_action_pressed("down"):
			new_pos.y -= 16
		elif event.is_action_pressed("down"):
			new_pos.y += 16
		if new_pos != map_position:
			map_position = new_pos
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.CURSOR)
			await get_tree().create_timer(0.25).timeout
			_repeat = true


## Enables movement of the cursor.
func enable() -> void:
	_set_active(true)


## Disables movement of the cursor.
func disable() -> void:
	_set_active(false)


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


func _get_new_position() -> Vector2i:
	var new_pos: Vector2i = map_position
	if Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
		new_pos.x -= 16
	elif Input.is_action_pressed("right"):
		new_pos.x += 16
	if Input.is_action_pressed("up") and not Input.is_action_pressed("down"):
		new_pos.y -= 16
	elif Input.is_action_pressed("down"):
		new_pos.y += 16
	return new_pos


func set_map_position(new_pos: Vector2i) -> void:
	## Sets cursor position relative to the map
	var old_pos: Vector2i = map_position
	map_position = new_pos.clamp(
		MapController.map.borders.position, MapController.map.borders.end - Vector2i(16, 16)
	)
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


func _set_active(active: bool) -> void:
	_active = active


func _corner_offset() -> Vector2i:
	return (
		Vector2i(MapController.map.get_map_camera().get_map_position())
		+ MapController.map.get_map_camera().get_map_offset()
	)
