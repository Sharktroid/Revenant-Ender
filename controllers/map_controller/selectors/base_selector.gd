class_name BaseSelector
extends Control

signal canceled

var unit: Unit

var _condition: Callable
var _minimum_range: int
var _maximum_range: int
var _icon: Cursor.icons
@onready var _selecting_position: Vector2i = unit.get_unit_path()[-1]

func _init(connected_unit: Unit, min_range: int, max_range: int, condition: Callable,
		icon: Cursor.icons = Cursor.icons.NONE) -> void:
	unit = connected_unit
	_minimum_range = min_range
	_maximum_range = max_range
	_condition = condition
	_icon = icon


func _ready() -> void:
	MapController.get_cursor().enable()
	unit.hide_movement_tiles()
	unit.remove_path()
	set_focus_mode(Control.FOCUS_ALL)
	grab_focus()


func _process(_delta: float) -> void:
	if _can_select():
		MapController.get_cursor().draw_icon(_icon)
	else:
		MapController.get_cursor().remove_icon()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_position_selected()
	elif event.is_action_pressed("ui_cancel"):
		_canceled()


func _has_point(_point: Vector2) -> bool:
	return true


func close() -> void:
	MapController.get_cursor().remove_icon()
	queue_free()


func _position_selected() -> void:
	pass # Abstract


func _can_select() -> bool:
	return false # Abstract


func _within_range() -> bool:
	var hovered_unit_pos: Vector2i = MapController.get_cursor().get_hovered_unit().position
	var dist: float = GenFunc.get_tile_distance(hovered_unit_pos, _selecting_position)
	return dist >= _minimum_range and dist <= _maximum_range


func _canceled() -> void:
	MapController.get_cursor().disable()
	unit.display_movement_tiles()
	unit.show_path()
	close()
