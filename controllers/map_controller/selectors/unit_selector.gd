class_name UnitSelector
extends Selector

signal selected(unit: Unit)

func _init(connected_unit: Unit, min_range: int, max_range: int, condition: Callable,
		icon: CursorController.icons = CursorController.icons.NONE) -> void:
	name = "Unit Selector"
	super(connected_unit, min_range, max_range, condition, icon)


func _position_selected() -> void:
	if _can_select():
		emit_signal("selected", CursorController.get_hovered_unit())
		close()


func _can_select() -> bool:
	return _within_range() and _condition.call(CursorController.get_hovered_unit())


func _within_range() -> bool:
	if CursorController.get_hovered_unit() != null:
		var hovered_unit_pos: Vector2i = CursorController.get_hovered_unit().position
		var dist: float = Utilities.get_tile_distance(hovered_unit_pos, _selecting_position)
		return dist >= _minimum_range and dist <= _maximum_range
	else:
		return false


func _canceled() -> void:
	emit_signal("selected", null)
	super()
