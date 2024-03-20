class_name TileSelector
extends Selector

signal selected(position: Vector2i)


func _position_selected() -> void:
	if _can_select():
		emit_signal("selected", CursorController.get_map_position())
		close()


func _can_select() -> bool:
	return _within_range() and _condition.call(CursorController.get_map_position())


func _within_range() -> bool:
	var dist: float = Utilities.get_tile_distance(CursorController.get_map_position(),
			_selecting_position)
	return dist >= _minimum_range and dist <= _maximum_range


func _canceled() -> void:
	emit_signal("selected", null)
	super()
