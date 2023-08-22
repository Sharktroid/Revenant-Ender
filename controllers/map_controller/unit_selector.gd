class_name UnitSelector
extends Control

signal selected(unit: Unit)
signal canceled

var unit: Unit

var _minimum_range: int
var _maximum_range: int
@onready var _selecting_position: Vector2i = unit.get_unit_path()[-1]

func _init(connected_unit: Unit, min_range: int, max_range: int) -> void:
	unit = connected_unit
	_minimum_range = min_range
	_maximum_range = max_range
	name = "Unit Selector"


func _ready() -> void:
	GenVars.cursor.enable()
	unit.hide_movement_tiles()
	unit.remove_path()
	set_focus_mode(Control.FOCUS_ALL)
	grab_focus()


func _process(_delta: float) -> void:
	if _within_range():
		GenVars.cursor.draw_icon(Cursor.icons.ATTACK)
	else:
		GenVars.cursor.remove_icon()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_position_selected()
	elif event.is_action_pressed("ui_cancel"):
		_canceled()


func _has_point(_point: Vector2) -> bool:
	return true


func close() -> void:
	unit.set_animation(unit.animations.IDLE)
	(GenVars.cursor as Cursor).remove_icon()
	queue_free()


func _position_selected() -> void:
	if _within_range():
		emit_signal("selected", GenVars.cursor.get_hovered_unit())
		close()


func _within_range() -> bool:
	if GenVars.cursor.get_hovered_unit() != null:
		var hovered_unit_pos: Vector2i = GenVars.cursor.get_hovered_unit().position
		var dist: int = GenFunc.get_tile_distance(hovered_unit_pos, _selecting_position)
		return dist >= _minimum_range and dist <= _maximum_range
	else:
		return false


func _canceled() -> void:
	emit_signal("selected", null)
	GenVars.cursor.disable()
	unit.display_movement_tiles()
	unit.show_path()
	close()
