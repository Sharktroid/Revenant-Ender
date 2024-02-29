extends Node

signal moved

## Icons that can be displayed.
enum icons {ATTACK, NONE}

var _position: Vector2i
var _icon_sprite: Sprite2D
var _hovered_unit: Unit = preload("res://units/unit.tscn").instantiate()
var _active: bool = true
var _delay: int = 0


func _init() -> void:
	set_true_pos(Vector2i())
	set_process_input(true)


func _process(_delta: float) -> void:
	_delay -= 1


func _input(_event: InputEvent) -> void:
	if is_active():
		match _event.get_class():
			"InputEventMouseMotion":
				var destination: Vector2 = MapController.get_map_camera().get_destination()
				if destination == MapController.get_map_camera().position:
					set_true_pos(Utilities.round_coords_to_tile(get_viewport().get_mouse_position() +
							(_corner_offset() as Vector2)))
			"InputEventKey":
				if _delay <= 0:
					var new_pos: Vector2i = get_true_pos()
					if Input.is_action_pressed("left"):
						new_pos.x -= 16
					elif Input.is_action_pressed("right") and not Input.is_action_pressed("left"):
						new_pos.x += 16
					if Input.is_action_pressed("up"):
						new_pos.y -= 16
					elif Input.is_action_pressed("down") and not Input.is_action_pressed("up"):
						new_pos.y += 16
					set_true_pos(new_pos)
					_delay = 3


func enable() -> void:
	_set_active(true)


func disable() -> void:
	_set_active(false)


func draw_icon(icon: icons) -> void:
	if not _icon_sprite:
		_icon_sprite = Sprite2D.new()
		_icon_sprite.centered = false
		add_child(_icon_sprite)
	match icon:
		icons.ATTACK:
			_icon_sprite.texture = preload("res://Cursor/attack.png")
			_icon_sprite.position = Vector2i(0, -16)


func remove_icon() -> void:
	if is_instance_valid(_icon_sprite):
		_icon_sprite.queue_free()


func set_rel_pos(new_pos: Vector2i) -> void:
	set_true_pos(new_pos + _corner_offset())


func get_rel_pos() -> Vector2i:
	return (_position - _corner_offset())


func set_true_pos(new_pos: Vector2i) -> void:
	## Sets cursor position relative to the map
	var old_pos: Vector2i = _position
	_position = new_pos.clamp(Vector2i(), MapController.map.get_size() - Vector2(16, 16))
	_position = ((_position - _corner_offset()).
			clamp(Vector2i(), Utilities.get_screen_size() - Vector2i(16, 16)) + _corner_offset())
	var map_move := Vector2i()
	for i: int in 2:
		if get_rel_pos()[i] < 16:
			map_move[i] -= 16
		elif get_rel_pos()[i] >= Utilities.get_screen_size()[i] - 16:
			map_move[i] += 16
	if map_move != Vector2i():
		MapController.get_map_camera().move(map_move)
	if _position != old_pos:
		moved.emit()


func get_true_pos() -> Vector2i:
	return _position


func get_area() -> Area2D:
	## Returns the cursor area.
	if MapController.map.has_node("Map Layer/Cursor Area"):
		return MapController.map.get_node("Map Layer/Cursor Area")
	else:
		return Area2D.new()


## Gets the unit under the cursor. Returns null if one is not there.
func get_hovered_unit() -> Unit:
	if is_instance_valid(_hovered_unit) and _hovered_unit.position == (get_true_pos() as Vector2):
		return _hovered_unit
	return null


func set_hovered_unit(new_hovered_unit: Unit) -> void:
	_hovered_unit = new_hovered_unit


func is_active() -> bool:
	return _active


func _set_active(active: bool) -> void:
	_active = active
	get_area().monitorable = active
	get_area().monitoring = active


func _corner_offset() -> Vector2i:
	return (Vector2i((MapController.get_map_camera().map_position))
			- MapController.get_map_camera().get_map_offset())
