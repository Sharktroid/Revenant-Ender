extends Node

signal moved

## Icons that can be displayed.
enum Icons { ATTACK, NONE }

var cursor_visible: bool = true
var map_position := Vector2i():
	set = _set_map_position
var screen_position: Vector2i:
	set(value):
		map_position = value + _corner_offset()
	get:
		return map_position - _corner_offset()

var _active: bool = true
var _delay: int = 0
var _repeat: bool = false


func _init() -> void:
	set_process_input(true)


func _ready() -> void:
	if Utilities.is_running_project():
		set_icon(Icons.NONE)
	else:
		queue_free()


func _physics_process(_delta: float) -> void:
	if is_active():
		if GameController.controller_type == GameController.ControllerTypes.MOUSE:
			var destination: Vector2 = MapController.get_map_camera().get_destination()
			if destination == MapController.get_map_camera().position:
				map_position = Utilities.round_coords_to_tile(
					get_viewport().get_mouse_position() + (_corner_offset() as Vector2)
				)
		else:
			if _delay <= 0 and _repeat:
				if (
					Input.is_action_pressed("left")
					or Input.is_action_pressed("right")
					or Input.is_action_pressed("up")
					or Input.is_action_pressed("down")
				):
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
						AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.CURSOR)
					_delay = 4
				else:
					_repeat = false
	_delay -= 1


func _input(event: InputEvent) -> void:
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


func enable() -> void:
	_set_active(true)


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


func get_area() -> Area2D:
	## Returns the cursor area.
	var path := NodePath("%s/MapLayer/CursorArea" % MapController.map.get_path())
	return get_node(path) if has_node(path) else Area2D.new()


func is_active() -> bool:
	return _active


func get_hovered_unit() -> Unit:
	for unit: Unit in MapController.map.get_units():
		if unit.position.round() as Vector2i == map_position and unit.visible:
			return unit
	return null


func _set_map_position(new_pos: Vector2i) -> void:
	## Sets cursor position relative to the map
	var old_pos: Vector2i = map_position
	map_position = new_pos.clamp(
		MapController.map.borders.position, MapController.map.borders.end - Vector2i(16, 16)
	)
	map_position = (
		(map_position - _corner_offset()).clamp(
			Vector2i(), Utilities.get_screen_size() - Vector2i(16, 16)
		)
		+ _corner_offset()
	)
	var map_move := Vector2i()
	for i: int in 2:
		if screen_position[i] < 16:
			map_move[i] -= 16
		elif screen_position[i] >= Utilities.get_screen_size()[i] - 16:
			map_move[i] += 16
	if map_move != Vector2i():
		MapController.get_map_camera().move(map_move)
	if map_position != old_pos:
		var emit_moved: Callable = func() -> void: moved.emit()
		emit_moved.call_deferred()


func _set_active(active: bool) -> void:
	_active = active
	get_area().monitorable = active
	get_area().monitoring = active


func _corner_offset() -> Vector2i:
	return (
		Vector2i(MapController.get_map_camera().map_position)
		- MapController.get_map_camera().get_map_offset()
	)
