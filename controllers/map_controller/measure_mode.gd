extends Node

var _selected: bool = false:
	set(value):
		_selected = value
		($CostPanel as PanelContainer).visible = _selected
var _path: Array[Vector2i]
var _path_object := CanvasGroup.new()
var _movement_type_index: int = 0:
	set(value):
		_movement_type_index = posmod(value, UnitClass.MovementTypes.size())
		_update_type_label()


func _enter_tree() -> void:
	CursorController.enable()
	CursorController.moved.connect(_on_cursor_move)
	_update_type_label()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		if not _selected:
			_selected = true
			_path = [CursorController.map_position]
		get_tree().root.set_input_as_handled()
	elif event.is_action_pressed("previous"):
		_movement_type_index -= 1
	elif event.is_action_pressed("next"):
		_movement_type_index += 1
	elif event.is_action_pressed("back"):
		if _selected:
			_selected = false
			_path = []
			_path_object.queue_free()
		else:
			queue_free()
			AudioPlayer.play_sound_effect(AudioPlayer.SoundEffects.DESELECT)
		get_tree().root.set_input_as_handled()


func _on_cursor_move() -> void:
	if not _path.is_empty():
		if _path.has(CursorController.map_position):
			_path = _path.slice(0, _path.find(CursorController.map_position) + 1)
		else:
			var cursor_pos: Vector2 = CursorController.map_position
			if MapController.map.get_terrain_cost(_get_movement_type(), cursor_pos) < INF:
				var path_end := _path.back() as Vector2
				if Utilities.get_tile_distance(path_end, CursorController.map_position) == 1:
					_path.append(CursorController.map_position)
				else:
					var new_path: Array[Vector2i] = _add_subsection(_path)
					_path = new_path
		if _path_object:
			_path_object.queue_free()
		_path_object = MapController.map.draw_path(_path)
		(%CostLabel as Label).text = Utilities.float_to_string(
			MapController.map.get_path_cost(_get_movement_type(), _path)
		)


func _add_subsection(path: Array[Vector2i]) -> Array[Vector2i]:
	var new_segment: Array[Vector2i] = MapController.map.get_movement_path(
		_get_movement_type(), path.back() as Vector2, CursorController.map_position, null
	).slice(1)

	if path.any(func(tile: Vector2i) -> bool: return new_segment.has(tile)) and path.size() > 1:
		return _add_subsection(path.slice(0, path.size() - 1))
	else:
		return path + new_segment


func _get_movement_type() -> UnitClass.MovementTypes:
	return UnitClass.MovementTypes.values()[_movement_type_index]


func _update_type_label() -> void:
	var raw_name: String = str(UnitClass.MovementTypes.find_key(_get_movement_type()))
	(%TypeLabel as Label).text = raw_name.capitalize()
