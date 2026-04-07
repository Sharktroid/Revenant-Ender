extends Node

var _path: Array[Vector2i]
var _path_object := CanvasGroup.new()
var _movement_type: UnitClass.MovementTypes


func _enter_tree() -> void:
	CursorController.enable()
	CursorController.moved.connect(_on_cursor_move)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		if _path.is_empty():
			_path = [CursorController.map_position]
		get_tree().root.set_input_as_handled()
	if event.is_action_pressed("back"):
		if _path.is_empty():
			queue_free()
		else:
			_path = []
			_path_object.queue_free()
		get_tree().root.set_input_as_handled()


func _exit_tree() -> void:
	_path_object.queue_free()


func _on_cursor_move() -> void:
	if not _path.is_empty():
		if _path.has(CursorController.map_position):
			_path = _path.slice(0, _path.find(CursorController.map_position) + 1)
		else:
			var cursor_pos: Vector2 = CursorController.map_position
			if MapController.map.get_terrain_cost(_movement_type, cursor_pos) < INF:
				var path_end := _path.back() as Vector2
				if Utilities.get_tile_distance(path_end, CursorController.map_position) == 1:
					_path.append(CursorController.map_position)
				else:
					var new_path: Array[Vector2i] = _add_subsection(_path)
					_path = new_path
		if _path_object:
			_path_object.queue_free()
		_path_object = MapController.map.draw_path(_path)
		(%MovementCost as Label).text = Utilities.float_to_string(MapController.map.get_path_cost(_movement_type, _path))



func _add_subsection(path: Array[Vector2i]) -> Array[Vector2i]:
	var new_segment: Array[Vector2i] = MapController.map.get_movement_path(
		_movement_type, path.back() as Vector2, CursorController.map_position, null
	).slice(1)

	if path.any(func(tile: Vector2i) -> bool: return new_segment.has(tile)) and path.size() > 1:
		return _add_subsection(path.slice(0, path.size() - 1))
	else:
		return path + new_segment
