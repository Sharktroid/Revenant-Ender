class_name TileSelector
extends Selector

signal selected(position: Vector2i)

func _init(connected_unit: Unit, min_range: int, max_range: int, condition: Callable,
		icon: Cursor.icons = Cursor.icons.NONE) -> void:
	name = "Tile Selector"
	super(connected_unit, min_range, max_range, condition, icon)


func _position_selected() -> void:
	if _can_select():
		emit_signal("selected", MapController.get_cursor().get_true_pos())
		close()


func _can_select() -> bool:
	return _within_range() and _condition.call(MapController.get_cursor().get_true_pos())


func _within_range() -> bool:
	var dist: float = GenFunc.get_tile_distance(MapController.get_cursor().get_true_pos(), _selecting_position)
	return dist >= _minimum_range and dist <= _maximum_range


func _canceled() -> void:
	emit_signal("selected", null)
	super()
