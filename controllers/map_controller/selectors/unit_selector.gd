class_name UnitSelector
extends Selector

signal selected(unit: Unit)


func _position_selected() -> void:
	if _can_select():
		selected.emit(CursorController.get_hovered_unit())
		close()


func _can_select() -> bool:
	return _within_range() and _condition.call(CursorController.get_hovered_unit())


func _within_range() -> bool:
	if CursorController.get_hovered_unit():
		var dist: float = Utilities.get_tile_distance(
			CursorController.get_hovered_unit().position, _selecting_position
		)
		return dist >= _minimum_range and dist <= _maximum_range
	return false


func _canceled() -> void:
	selected.emit(null)
	super()
