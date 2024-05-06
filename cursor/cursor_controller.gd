extends Node

signal moved

## Icons that can be displayed.
enum Icons {ATTACK, NONE}

var hovered_unit: Unit:
	get:
		if is_instance_valid(hovered_unit) and hovered_unit.position == (map_position as Vector2):
			return hovered_unit
		else:
			return null
var cursor_visible: bool = true
var map_position := Vector2i():
	set = _set_map_position
var screen_position: Vector2i:
	set(value):
		map_position = value + _corner_offset()
	get:
		return (map_position - _corner_offset())

var _icon_sprite: Sprite2D
var _active: bool = true
var _delay: int = 0
var _repeat: bool = false


func _init() -> void:
	set_process_input(true)


func _physics_process(_delta: float) -> void:
	if is_active():
		if GameController.controller_type == GameController.ControllerTypes.MOUSE:
			if (MapController.get_map_camera().get_destination() ==
					(MapController.get_map_camera().position as Vector2i)):
				map_position = Utilities.round_coords_to_tile(get_viewport().get_mouse_position()
				+ (_corner_offset() as Vector2))
		else:
			if _delay <= 0 and _repeat:
				if (Input.is_action_pressed("left") or Input.is_action_pressed("right")
						or Input.is_action_pressed("up") or Input.is_action_pressed("down")):
					var new_pos: Vector2i = map_position
					var old_pos: Vector2i = new_pos
					if Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
						new_pos.x -= 16
					elif Input.is_action_pressed("right"):
						new_pos.x += 16
					if Input.is_action_pressed("up") and not Input.is_action_pressed("down"):
						new_pos.y -= 16
					elif Input.is_action_pressed("down"):
						new_pos.y += 16
					map_position = new_pos
					if new_pos != old_pos and map_position != old_pos:
						AudioPlayer.play_sound_effect(AudioPlayer.CURSOR)
					_delay = 4
				else:
					_repeat = false
	_delay -= 1


func _input(event: InputEvent) -> void:
	var repeat_callable: Callable = func() -> void:
		AudioPlayer.play_sound_effect(AudioPlayer.CURSOR)
		await get_tree().create_timer(0.25).timeout
		_repeat = true
	if is_active():
		var new_pos: Vector2i = map_position
		if event.is_action_pressed("left") and not Input.is_action_pressed("right"):
			new_pos.x -= 16
			repeat_callable.call()
		elif event.is_action_pressed("right"):
			new_pos.x += 16
			repeat_callable.call()
		if event.is_action_pressed("up") and not Input.is_action_pressed("down"):
			new_pos.y -= 16
			repeat_callable.call()
		elif event.is_action_pressed("down"):
			new_pos.y += 16
			repeat_callable.call()
		map_position = new_pos


func enable() -> void:
	_set_active(true)


func disable() -> void:
	_set_active(false)


func draw_icon(icon: Icons) -> void:
	if not _icon_sprite:
		_icon_sprite = Sprite2D.new()
		_icon_sprite.centered = false
		add_child(_icon_sprite)
	match icon:
		Icons.ATTACK:
			_icon_sprite.texture = preload("res://Cursor/attack.png")
			_icon_sprite.position = Vector2i(0, -16)


func remove_icon() -> void:
	if is_instance_valid(_icon_sprite):
		_icon_sprite.queue_free()


func get_area() -> Area2D:
	## Returns the cursor area.
	var path := NodePath("%s/Map Layer/Cursor Area" % MapController.map.get_path())
	return get_node(path) if has_node(path) else Area2D.new()


func is_active() -> bool:
	return _active


func _set_map_position(new_pos: Vector2i) -> void:
	## Sets cursor position relative to the map
	var old_pos: Vector2i = map_position
	map_position = new_pos.clamp(MapController.map.borders.position,
			MapController.map.borders.end - Vector2i(16, 16))
	map_position = ((map_position - _corner_offset()).
			clamp(Vector2i(), Utilities.get_screen_size() - Vector2i(16, 16)) + _corner_offset())
	var map_move := Vector2i()
	for i: int in 2:
		if screen_position[i] < 16:
			map_move[i] -= 16
		elif screen_position[i] >= Utilities.get_screen_size()[i] - 16:
			map_move[i] += 16
	if map_move != Vector2i():
		MapController.get_map_camera().move(map_move)
	if map_position != old_pos:
		moved.emit()


func _set_active(active: bool) -> void:
	_active = active
	get_area().monitorable = active
	get_area().monitoring = active


func _corner_offset() -> Vector2i:
	return (Vector2i((MapController.get_map_camera().map_position))
			- MapController.get_map_camera().get_map_offset())
