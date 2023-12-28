class_name Cursor
extends Control

signal moved

## Icons that can be displayed.
enum icons {ATTACK, NONE}

var _icon_sprite: Sprite2D
var _rel_pos: Vector2i
var _true_origin: Vector2
var _hovered_unit: Unit = load("uid://klwwp0vjyw6").instantiate()
var _active: bool = true


func _ready() -> void:
	set_rel_pos(position)
	set_process_input(true)


func _process(_delta):
	var tick_timer: int = Engine.get_physics_frames() % 32
	if tick_timer <= 20:
		$Icon.frame = 0
	elif tick_timer <= 22 or tick_timer > 30:
		$Icon.frame = 1
	else:
		$Icon.frame = 2


func _physics_process(_delta: float) -> void:
	if is_active():
		if GameController.controller_type == GameController.controller_types.MOUSE:
			var destination: Vector2 = MapController.get_map_camera().get_destination()
			if destination == MapController.get_map_camera().position:
				var mouse_position = get_viewport().get_mouse_position()
				set_rel_pos((mouse_position) - Vector2(MapController.get_map_camera().get_map_offset()))
		else:
			var new_pos := Vector2i()
			if get_rel_pos() == Vector2i(_true_origin) and is_processing_input():
				if Input.is_action_pressed("left"):
					new_pos.x -= 16
				elif Input.is_action_pressed("right") and not Input.is_action_pressed("left"):
					new_pos.x += 16
				if Input.is_action_pressed("up"):
					new_pos.y -= 16
				elif Input.is_action_pressed("down") and not Input.is_action_pressed("up"):
					new_pos.y += 16
			move(new_pos)
	if position != Vector2(_rel_pos + MapController.get_map_camera().get_map_offset()):
		_true_origin = _true_origin.move_toward(get_rel_pos(),
				max(1, _true_origin.distance_to(get_rel_pos())/16) * 4)
		position = _true_origin + Vector2(MapController.get_map_camera().get_map_offset())


func set_true_pos(new_pos: Vector2i) -> void:
	# Sets cursor position relative to the map
	set_rel_pos(new_pos - Vector2i(MapController.get_map_camera().true_origin))


func get_true_pos() -> Vector2i:
	return get_rel_pos() + Vector2i(MapController.get_map_camera().true_origin)


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
	var top_bounds: Vector2i = Vector2i(4, 4)
	var bottom_bounds: Vector2i = GenVars.get_screen_size() - Vector2i(4, 4)
	new_pos = GenFunc.round_coords_to_tile(new_pos)
	var map_move := Vector2i()
	var lower_bound: Vector2i = (GenVars.get_screen_size()
			- MapController.map.get_rel_lower_border())
	for i in 2:
		if MapController.map.get_rel_upper_border()[i] >= 0:
			top_bounds[i] = MapController.map.get_rel_upper_border()[i]
		if MapController.map.get_rel_lower_border()[i] >= 0:
			bottom_bounds[i] = lower_bound[i]

		while new_pos[i] <= -16:
			new_pos[i] += 16
		while new_pos[i] + 16 >= GenVars.get_screen_size()[i] + 16:
			new_pos[i] -= 16

		while top_bounds[i] > new_pos[i]:
			map_move[i] -= 16
			new_pos[i] += 16
		while bottom_bounds[i] < new_pos[i] + 16:
			map_move[i] += 16
			new_pos[i] -= 16

	if map_move != Vector2i():
		MapController.get_map_camera().move(map_move)
	if _rel_pos != new_pos:
		_rel_pos = new_pos
		emit_signal("moved")


func get_rel_pos() -> Vector2i:
	return _rel_pos


func get_area() -> Area2D:
	# Returns the cursor area.
	if MapController.map.has_node("Map Layer/Cursor Area"):
		return MapController.map.get_node("Map Layer/Cursor Area")
	else:
		return Area2D.new()


func move(new_pos: Vector2i) -> void:
	set_rel_pos(new_pos + get_rel_pos())


func can_move(new_pos: Vector2i) -> bool:
	var old_pos: Vector2i = get_rel_pos()
	move(new_pos)
	var answer: bool
	if get_rel_pos() == old_pos:
		answer = false
	else:
		answer = true
	set_rel_pos(old_pos)
	return answer


## Gets the unit under the cursor. Returns null if one is not there.
func get_hovered_unit() -> Unit:
	if is_instance_valid(_hovered_unit) and _hovered_unit.get_area().overlaps_area(get_area()):
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
